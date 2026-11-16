using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Thrive.Application.Consent;
using Thrive.Contracts;
using Thrive.Infrastructure.Persistence;

namespace Thrive.Tests;

public sealed class ConsentApiTests
{
    [Fact]
    public async Task AnonymousClientCannotReadOrWriteConsent()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();

        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/v1/me")).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/v1/me/consents")).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized,
            (await client.PutAsJsonAsync("/api/v1/me/consents", NewRequest())).StatusCode);
    }

    [Fact]
    public async Task ConsentIsPersistedWithOptionalResearchAndRestoredByAnotherClient()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Authenticate(client, "student-a");
        Assert.Equal("null", await client.GetStringAsync("/api/v1/me/consents"));

        var response = await client.PutAsJsonAsync("/api/v1/me/consents", NewRequest());
        response.EnsureSuccessStatusCode();
        var saved = await response.Content.ReadFromJsonAsync<ConsentResponse>();
        Assert.NotNull(saved);
        Assert.True(saved.ServiceUse);
        Assert.False(saved.ResearchUse);

        using var secondClient = factory.CreateClient();
        await Authenticate(secondClient, "student-a");
        var restored = await secondClient.GetFromJsonAsync<ConsentResponse>("/api/v1/me/consents");
        Assert.Equal(saved, restored);

        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ThriveDbContext>();
        Assert.Equal(1, await db.ConsentDecisions.CountAsync());
        Assert.Equal(1, await db.ConsentAuditEvents.CountAsync());
    }

    [Theory]
    [InlineData("student-b")]
    [InlineData("student-other-university")]
    public async Task ConsentIsIsolatedBySubjectAndUniversity(string otherPersona)
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Authenticate(client, "student-a");
        (await client.PutAsJsonAsync("/api/v1/me/consents", NewRequest())).EnsureSuccessStatusCode();

        await Authenticate(client, otherPersona);
        Assert.Equal("null", await client.GetStringAsync("/api/v1/me/consents"));
    }

    [Fact]
    public async Task InvalidPolicyAndServiceRefusalDoNotWriteRecords()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Authenticate(client, "student-a");

        var stale = await client.PutAsJsonAsync("/api/v1/me/consents", NewRequest() with { PolicyVersion = "outdated" });
        var refused = await client.PutAsJsonAsync("/api/v1/me/consents", NewRequest() with { ServiceUse = false });
        Assert.Equal(HttpStatusCode.BadRequest, stale.StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, refused.StatusCode);
        Assert.Equal("application/problem+json", stale.Content.Headers.ContentType?.MediaType);
        Assert.Equal("null", await client.GetStringAsync("/api/v1/me/consents"));
    }

    [Fact]
    public async Task UpdatedResearchChoicePreservesDecisionHistoryAndAudit()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Authenticate(client, "student-a");
        (await client.PutAsJsonAsync("/api/v1/me/consents", NewRequest())).EnsureSuccessStatusCode();
        (await client.PutAsJsonAsync("/api/v1/me/consents", NewRequest() with { ResearchUse = true })).EnsureSuccessStatusCode();

        var latest = await client.GetFromJsonAsync<ConsentResponse>("/api/v1/me/consents");
        Assert.True(latest?.ResearchUse);
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ThriveDbContext>();
        Assert.Equal(2, await db.ConsentDecisions.CountAsync());
        Assert.Equal(2, await db.ConsentAuditEvents.CountAsync());
    }

    [Theory]
    [InlineData("Development", false)]
    [InlineData("Production", true)]
    public async Task DemoSessionsAreUnavailableUnlessExplicitlyEnabledInDevelopment(string environment, bool enabled)
    {
        using var factory = new ApiFactory(enabled, environment);
        using var client = factory.CreateInitializedClient();

        var response = await client.PostAsJsonAsync("/api/v1/development/session", new DevelopmentSessionRequest("student-a"));
        Assert.True(response.StatusCode is HttpStatusCode.NotFound or HttpStatusCode.Unauthorized);
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/v1/me")).StatusCode);
    }

    [Fact]
    public async Task HealthDoesNotPretendDatabaseIsReadyWhenItIsUnconfigured()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();

        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/health/live")).StatusCode);
        Assert.Equal(HttpStatusCode.ServiceUnavailable, (await client.GetAsync("/health/ready")).StatusCode);
        var policy = await client.GetFromJsonAsync<ConsentPolicyResponse>("/api/v1/consent-policies/current");
        Assert.Equal(ConsentPolicy.Current.Version, policy?.Version);
    }

    private static RecordConsentRequest NewRequest() => new(ConsentPolicy.Current.Version, true, false);

    private static async Task Authenticate(HttpClient client, string persona)
    {
        var response = await client.PostAsJsonAsync("/api/v1/development/session", new DevelopmentSessionRequest(persona));
        response.EnsureSuccessStatusCode();
        var session = await response.Content.ReadFromJsonAsync<DevelopmentSessionResponse>();
        Assert.NotNull(session);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", session.AccessToken);
    }
}

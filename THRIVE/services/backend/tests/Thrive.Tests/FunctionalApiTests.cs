using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Thrive.Application.Consent;
using Thrive.Application.Screening;
using Thrive.Contracts;
using Thrive.Domain.Referrals;
using Thrive.Infrastructure.Persistence;

namespace Thrive.Tests;

public sealed class FunctionalApiTests
{
    [Fact]
    public async Task ScreeningResumesValidatesAndSubmitsOnlyServerComputedTotal()
    {
        using var factory = new ApiFactory(); using var client = factory.CreateInitializedClient();
        await Login(client, "student-a");
        Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync("/api/v1/instruments")).StatusCode);
        await Consent(client);
        var instruments = (await client.GetFromJsonAsync<Instrument[]>("/api/v1/instruments"))!;
        Assert.Single(instruments!);
        var session = await Start(client);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsync($"/api/v1/screening/sessions/{session.Id}/submit", null)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/v1/screening/sessions/{session.Id}/answers/navigation", new AnswerRequest(9))).StatusCode);
        foreach (var item in instruments[0].Items)
            (await client.PutAsJsonAsync($"/api/v1/screening/sessions/{session.Id}/answers/{item.Code}", new AnswerRequest(2))).EnsureSuccessStatusCode();
        var restored = await client.GetFromJsonAsync<SessionResponse>($"/api/v1/screening/sessions/{session.Id}");
        Assert.Equal(3, restored!.Answers.Length);
        var submitted = await client.PostAsync($"/api/v1/screening/sessions/{session.Id}/submit", null);
        submitted.EnsureSuccessStatusCode();
        var result = await submitted.Content.ReadFromJsonAsync<ScreeningResultResponse>();
        Assert.Equal(6, result!.RawScore); Assert.Equal("Demo", result.State); Assert.True(result.IsDemo);
        var repeated = await (await client.PostAsync($"/api/v1/screening/sessions/{session.Id}/submit", null)).Content.ReadFromJsonAsync<ScreeningResultResponse>();
        Assert.Equal(result, repeated);
        Assert.Equal(HttpStatusCode.Conflict, (await client.PutAsJsonAsync($"/api/v1/screening/sessions/{session.Id}/answers/navigation", new AnswerRequest(0))).StatusCode);
        var history = (await client.GetFromJsonAsync<SessionResponse[]>("/api/v1/me/screenings"))!; Assert.Single(history); Assert.Equal("Completed", history[0].Status);
    }

    [Theory]
    [InlineData("student-b")]
    [InlineData("student-other-university")]
    public async Task SessionsAreHiddenAcrossUsersAndUniversities(string persona)
    {
        using var factory = new ApiFactory(); using var client = factory.CreateInitializedClient();
        await Login(client, "student-a"); await Consent(client); var session = await Start(client);
        await Login(client, persona); await Consent(client);
        Assert.Equal(HttpStatusCode.NotFound, (await client.GetAsync($"/api/v1/screening/sessions/{session.Id}")).StatusCode);
        Assert.Empty((await client.GetFromJsonAsync<SessionResponse[]>("/api/v1/me/screenings"))!);
    }

    [Fact]
    public async Task ReferralRequiresSharingConsentAndUsesControlledStatusTransitions()
    {
        using var factory = new ApiFactory(); using var client = factory.CreateInitializedClient();
        await Login(client, "student-a"); await Consent(client);
        var services = (await client.GetFromJsonAsync<ServiceResponse[]>("/api/v1/services?level=Counseling"))!; Assert.Single(services);
        Assert.True(services[0].IsDemo); Assert.False(services[0].Verified); Assert.Null(services[0].ContactUrl);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync("/api/v1/referrals", new ReferralRequest(services[0].Id, false))).StatusCode);
        var response = await client.PostAsJsonAsync("/api/v1/referrals", new ReferralRequest(services[0].Id, true)); response.EnsureSuccessStatusCode();
        var referral = (await response.Content.ReadFromJsonAsync<ReferralResponse>())!;
        Assert.Equal("Requested", referral.Status);
        Assert.Equal(HttpStatusCode.Conflict, (await client.PostAsJsonAsync("/api/v1/referrals", new ReferralRequest(services[0].Id, true))).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync("/api/v1/admin/referrals")).StatusCode);
        await Login(client, "admin");
        Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync("/api/v1/me/screenings")).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await client.PutAsJsonAsync($"/api/v1/admin/referrals/{referral.Id}/status", new ReferralStatusRequest("Completed"))).StatusCode);
        foreach (var status in new[] { "Received", "Scheduled", "Completed" })
            (await client.PutAsJsonAsync($"/api/v1/admin/referrals/{referral.Id}/status", new ReferralStatusRequest(status))).EnsureSuccessStatusCode();
        var adminJson = await client.GetStringAsync("/api/v1/admin/referrals");
        Assert.DoesNotContain("subjectId", adminJson); Assert.DoesNotContain("demo-student-a", adminJson);
        await Login(client, "student-a");
        Assert.Equal(HttpStatusCode.Conflict, (await client.PostAsync($"/api/v1/me/referrals/{referral.Id}/cancel", null)).StatusCode);
        Assert.Equal("Completed", (await client.GetFromJsonAsync<ReferralResponse[]>("/api/v1/me/referrals"))![0].Status);
    }

    [Fact]
    public async Task AdminCannotMutateOtherUniversityAndReportsSuppressSmallCells()
    {
        using var factory = new ApiFactory(); using var client = factory.CreateInitializedClient();
        await Login(client, "admin");
        var services = await client.GetFromJsonAsync<ServiceResponse[]>("/api/v1/admin/services");
        var service = services![0];
        var body = new ServiceWrite(service.Level, service.NameAr, service.NameEn, service.DescriptionAr, service.DescriptionEn, service.HoursAr, service.HoursEn, service.LocationAr, service.LocationEn, service.BookingMethod, null, false, true);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/v1/admin/services/{service.Id}", body with { Verified = true })).StatusCode);
        var report = await client.GetFromJsonAsync<AggregateReportResponse>("/api/v1/admin/reports/aggregate");
        Assert.Null(report!.ScreeningsCount); Assert.Null(report.ReferralsCount); Assert.Null(report.CompletedReferralsCount); Assert.Equal(5, report.MinCellSize);
        await Login(client, "admin-other-university");
        Assert.Equal(HttpStatusCode.NotFound, (await client.PutAsJsonAsync($"/api/v1/admin/services/{service.Id}", body)).StatusCode);
    }

    [Fact]
    public async Task DraftGuideIsHiddenUntilPublishedAndSourceIsPreserved()
    {
        using var factory = new ApiFactory(); using var client = factory.CreateInitializedClient();
        await Login(client, "admin");
        var body = new ResourceWrite("workflow-guide", "دليل تجربة", "Workflow guide", "ملخص", "Summary", "نص استخدام المنتج", "Product help text", "Using THRIVE", "Product documentation", "v1", false);
        var response = await client.PostAsJsonAsync("/api/v1/admin/resources", body); response.EnsureSuccessStatusCode();
        var draft = (await response.Content.ReadFromJsonAsync<ResourceResponse>())!;
        Assert.True(draft.IsDemo); Assert.Null(draft.ReviewedAtUtc);
        await Login(client, "student-a"); await Consent(client);
        Assert.Equal(HttpStatusCode.NotFound, (await client.GetAsync($"/api/v1/guide/resources/{draft.Id}")).StatusCode);
        await Login(client, "admin"); (await client.PutAsJsonAsync($"/api/v1/admin/resources/{draft.Id}", body with { Published = true })).EnsureSuccessStatusCode();
        await Login(client, "student-a");
        var published = await client.GetFromJsonAsync<ResourceResponse>($"/api/v1/guide/resources/{draft.Id}"); Assert.Equal(body.Source, published!.Source);
    }

    [Fact]
    public async Task WithdrawalIsAppendOnlyAndImmediatelyRevokesFeatureAccess()
    {
        using var factory = new ApiFactory(); using var client = factory.CreateInitializedClient();
        await Login(client, "student-a"); await Consent(client);
        (await client.PostAsync("/api/v1/me/consents/withdraw", null)).EnsureSuccessStatusCode();
        var choice = await client.GetFromJsonAsync<ConsentResponse>("/api/v1/me/consents"); Assert.False(choice!.ServiceUse); Assert.False(choice.ResearchUse);
        Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync("/api/v1/services")).StatusCode);
        using var scope = factory.Services.CreateScope(); var db = scope.ServiceProvider.GetRequiredService<ThriveDbContext>();
        Assert.Equal(2, await db.ConsentDecisions.CountAsync()); Assert.Equal(2, await db.ConsentAuditEvents.CountAsync());
        await Consent(client); Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/api/v1/services")).StatusCode);
    }

    [Theory]
    [InlineData("Requested", "Received", true)]
    [InlineData("Requested", "Completed", false)]
    [InlineData("Received", "Scheduled", true)]
    [InlineData("Scheduled", "Completed", true)]
    [InlineData("Completed", "Received", false)]
    [InlineData("Cancelled", "Scheduled", false)]
    public void ReferralPolicyGuardsTransitions(string from, string to, bool expected) => Assert.Equal(expected, Referral.CanTransition(from, to, false));

    private static async Task Login(HttpClient client, string persona)
    {
        var response = await client.PostAsJsonAsync("/api/v1/development/session", new DevelopmentSessionRequest(persona)); response.EnsureSuccessStatusCode();
        var session = await response.Content.ReadFromJsonAsync<DevelopmentSessionResponse>();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", session!.AccessToken);
    }
    private static async Task Consent(HttpClient client) => (await client.PutAsJsonAsync("/api/v1/me/consents", new RecordConsentRequest(ConsentPolicy.Current.Version, true, false))).EnsureSuccessStatusCode();
    private static async Task<SessionResponse> Start(HttpClient client)
    {
        var response = await client.PostAsJsonAsync("/api/v1/screening/sessions", new StartSessionRequest(DemoInstrument.Code)); response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<SessionResponse>())!;
    }
}

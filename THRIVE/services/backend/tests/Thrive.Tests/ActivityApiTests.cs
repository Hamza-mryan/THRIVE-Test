using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Thrive.Application.Consent;
using Thrive.Application.Screening;
using Thrive.Contracts;
using Thrive.Infrastructure.Persistence;

namespace Thrive.Tests;

public sealed class ActivityApiTests
{
    [Fact]
    public async Task MoodIsOptionalOwnedAndEditableWithoutAffectingScreening()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Login(client, "student-a");
        var day = DateOnly.FromDateTime(DateTime.UtcNow).ToString("yyyy-MM-dd");
        Assert.Equal(HttpStatusCode.Forbidden, (await client.PutAsJsonAsync($"/api/v1/me/moods/{day}", new MoodRequest(3))).StatusCode);
        await Consent(client);
        (await client.PutAsJsonAsync($"/api/v1/me/moods/{day}", new MoodRequest(2))).EnsureSuccessStatusCode();
        (await client.PutAsJsonAsync($"/api/v1/me/moods/{day}", new MoodRequest(5))).EnsureSuccessStatusCode();
        var own = await client.GetFromJsonAsync<MoodResponse[]>($"/api/v1/me/moods?from={day}&to={day}");
        Assert.Equal(5, Assert.Single(own!).Value);
        var summary = await client.GetFromJsonAsync<ActivitySummaryResponse>("/api/v1/me/activity");
        Assert.Equal(0, summary!.CompletedScreenings);

        foreach (var other in new[] { "student-b", "student-other-university" })
        {
            await Login(client, other);
            await Consent(client);
            Assert.Empty((await client.GetFromJsonAsync<MoodResponse[]>($"/api/v1/me/moods?from={day}&to={day}"))!);
        }
        await Login(client, "admin");
        Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync("/api/v1/me/activity")).StatusCode);
        await Login(client, "student-a");
        Assert.Equal(HttpStatusCode.NoContent, (await client.DeleteAsync($"/api/v1/me/moods/{day}")).StatusCode);
        Assert.Empty((await client.GetFromJsonAsync<MoodResponse[]>($"/api/v1/me/moods?from={day}&to={day}"))!);
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ThriveDbContext>();
        Assert.Equal(3, await db.ActivityAuditEvents.CountAsync());
        Assert.Equal(0, await db.ScreeningSessions.CountAsync());
    }

    [Fact]
    public async Task InvalidMoodAndOversizedRangesAreRejected()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Login(client, "student-a");
        await Consent(client);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        foreach (var value in new[] { 0, 6 })
            Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/v1/me/moods/{today:yyyy-MM-dd}", new MoodRequest(value))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/v1/me/moods/{today.AddDays(3):yyyy-MM-dd}", new MoodRequest(3))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.GetAsync($"/api/v1/me/moods?from={today.AddDays(-40):yyyy-MM-dd}&to={today:yyyy-MM-dd}")).StatusCode);
    }

    [Fact]
    public async Task ActivitySummaryAndScreeningAuditReflectRealOperations()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Login(client, "student-a");
        await Consent(client);
        var response = await client.PostAsJsonAsync("/api/v1/screening/sessions", new StartSessionRequest(DemoInstrument.Code));
        response.EnsureSuccessStatusCode();
        var session = (await response.Content.ReadFromJsonAsync<SessionResponse>())!;
        var activity = (await client.GetFromJsonAsync<ActivitySummaryResponse>("/api/v1/me/activity"))!;
        Assert.Equal(1, activity.InProgressScreenings);
        Assert.NotNull(activity.LatestScreeningAtUtc);
        foreach (var item in DemoInstrument.Definition.Items)
            (await client.PutAsJsonAsync($"/api/v1/screening/sessions/{session.Id}/answers/{item.Code}", new AnswerRequest(1))).EnsureSuccessStatusCode();
        (await client.PostAsync($"/api/v1/screening/sessions/{session.Id}/submit", null)).EnsureSuccessStatusCode();
        activity = (await client.GetFromJsonAsync<ActivitySummaryResponse>("/api/v1/me/activity"))!;
        Assert.Equal(1, activity.CompletedScreenings);
        Assert.Equal(0, activity.InProgressScreenings);
        using var scope = factory.Services.CreateScope();
        var events = await scope.ServiceProvider.GetRequiredService<ThriveDbContext>().ActivityAuditEvents.ToListAsync();
        Assert.Equal(5, events.Count);
        Assert.Contains(events, value => value.Action == "screening.submitted");
        Assert.All(events, value => Assert.Equal(session.Id.ToString(), value.ResourceId));
    }

    private static async Task Login(HttpClient client, string persona)
    {
        var session = await (await client.PostAsJsonAsync("/api/v1/development/session", new DevelopmentSessionRequest(persona))).Content.ReadFromJsonAsync<DevelopmentSessionResponse>();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", session!.AccessToken);
    }
    private static async Task Consent(HttpClient client) => (await client.PutAsJsonAsync("/api/v1/me/consents", new RecordConsentRequest(ConsentPolicy.Current.Version, true, false))).EnsureSuccessStatusCode();
}

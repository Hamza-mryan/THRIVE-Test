using Thrive.Api.Identity;
using Thrive.Application.Activity;
using Thrive.Contracts;
using Thrive.Domain.Activity;

namespace Thrive.Api.Endpoints;

public static class ActivityEndpoints
{
    public static void MapActivityEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/v1/me").RequireAuthorization(IdentityRegistration.StudentPolicy)
            .AddEndpointFilter<FeatureExceptionFilter>().AddEndpointFilter<CurrentConsentFilter>().WithTags("Student activity");
        group.MapGet("/activity", async (HttpContext context, StudentActivity activity, CancellationToken ct) =>
        {
            var result = await activity.SummaryAsync(context.GetCurrentStudent(), ct);
            return new ActivitySummaryResponse(result.CompletedScreenings, result.InProgressScreenings, result.OpenReferrals, result.LatestScreeningAtUtc);
        });
        group.MapGet("/moods", async (DateOnly from, DateOnly to, HttpContext context, StudentActivity activity, CancellationToken ct) =>
            (await activity.MoodAsync(context.GetCurrentStudent(), from, to, ct)).Select(Response));
        group.MapPut("/moods/{day}", async (DateOnly day, MoodRequest request, HttpContext context, StudentActivity activity, CancellationToken ct) =>
            Response(await activity.RecordAsync(context.GetCurrentStudent(), day, request.Value, ct)));
        group.MapDelete("/moods/{day}", async (DateOnly day, HttpContext context, StudentActivity activity, CancellationToken ct) =>
        {
            await activity.DeleteAsync(context.GetCurrentStudent(), day, ct);
            return Results.NoContent();
        });
    }
    private static MoodResponse Response(DailyMood mood) => new(mood.Day, mood.Value, mood.UpdatedAtUtc);
}

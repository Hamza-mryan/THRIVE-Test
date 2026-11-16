using Thrive.Application.Features;
using Thrive.Application.Identity;
using Thrive.Domain;
using Thrive.Domain.Activity;

namespace Thrive.Application.Activity;

public sealed record ActivitySummary(int CompletedScreenings, int InProgressScreenings, int OpenReferrals, DateTimeOffset? LatestScreeningAtUtc);

public interface IStudentActivityStore
{
    Task<ActivitySummary> SummaryAsync(CurrentStudent student, CancellationToken ct);
    Task<IReadOnlyList<DailyMood>> MoodAsync(CurrentStudent student, DateOnly from, DateOnly to, CancellationToken ct);
    Task<DailyMood?> FindMoodAsync(CurrentStudent student, DateOnly day, CancellationToken ct);
    Task SaveMoodAsync(DailyMood mood, bool isNew, ActivityAuditEvent audit, CancellationToken ct);
    Task DeleteMoodAsync(DailyMood mood, ActivityAuditEvent audit, CancellationToken ct);
}

public sealed class StudentActivity(IStudentActivityStore store, TimeProvider clock)
{
    public Task<ActivitySummary> SummaryAsync(CurrentStudent student, CancellationToken ct) => store.SummaryAsync(student, ct);

    public Task<IReadOnlyList<DailyMood>> MoodAsync(CurrentStudent student, DateOnly from, DateOnly to, CancellationToken ct)
    {
        FeatureValidation.Require(to >= from && to.DayNumber - from.DayNumber <= 31, "Choose a date range of at most 32 days.");
        return store.MoodAsync(student, from, to, ct);
    }

    public async Task<DailyMood> RecordAsync(CurrentStudent student, DateOnly day, int value, CancellationToken ct)
    {
        FeatureValidation.Require(value is >= 1 and <= 5, "Choose a feeling from 1 to 5.");
        var todayUtc = DateOnly.FromDateTime(clock.GetUtcNow().UtcDateTime);
        FeatureValidation.Require(day >= todayUtc.AddDays(-365) && day <= todayUtc.AddDays(1), "The diary date is outside the allowed range.");
        var mood = await store.FindMoodAsync(student, day, ct);
        var isNew = mood is null;
        mood ??= new DailyMood { SubjectId = student.SubjectId, UniversityId = student.UniversityId, Day = day };
        if (!isNew && mood.Value == value) return mood;
        mood.Value = value;
        mood.UpdatedAtUtc = UtcTimestamp.Normalize(clock.GetUtcNow());
        await store.SaveMoodAsync(mood, isNew, Audit(student, isNew ? "mood.recorded" : "mood.updated", mood.Id), ct);
        return mood;
    }

    public async Task DeleteAsync(CurrentStudent student, DateOnly day, CancellationToken ct)
    {
        var mood = await store.FindMoodAsync(student, day, ct);
        if (mood is not null) await store.DeleteMoodAsync(mood, Audit(student, "mood.deleted", mood.Id), ct);
    }

    private ActivityAuditEvent Audit(CurrentStudent student, string action, Guid id) => new()
    {
        SubjectId = student.SubjectId,
        UniversityId = student.UniversityId,
        Action = action,
        ResourceId = id.ToString(),
        OccurredAtUtc = UtcTimestamp.Normalize(clock.GetUtcNow())
    };
}

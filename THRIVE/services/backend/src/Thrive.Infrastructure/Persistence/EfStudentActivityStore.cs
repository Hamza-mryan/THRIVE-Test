using Microsoft.EntityFrameworkCore;
using Thrive.Application.Activity;
using Thrive.Application.Identity;
using Thrive.Domain.Activity;

namespace Thrive.Infrastructure.Persistence;

public sealed class EfStudentActivityStore(ThriveDbContext db) : IStudentActivityStore
{
    public async Task<ActivitySummary> SummaryAsync(CurrentStudent student, CancellationToken ct)
    {
        var sessions = db.ScreeningSessions.Where(x => x.SubjectId == student.SubjectId && x.UniversityId == student.UniversityId);
        var completed = await sessions.CountAsync(x => x.CompletedAtUtc != null, ct);
        var inProgress = await sessions.CountAsync(x => x.CompletedAtUtc == null, ct);
        var last = await sessions.OrderByDescending(x => x.StartedAtUtc).Select(x => (DateTimeOffset?)x.StartedAtUtc).FirstOrDefaultAsync(ct);
        var open = await db.Referrals.CountAsync(x => x.SubjectId == student.SubjectId && x.UniversityId == student.UniversityId
            && (x.Status == "Requested" || x.Status == "Received" || x.Status == "Scheduled"), ct);
        return new ActivitySummary(completed, inProgress, open, last);
    }

    public async Task<IReadOnlyList<DailyMood>> MoodAsync(CurrentStudent student, DateOnly from, DateOnly to, CancellationToken ct) =>
        await db.DailyMoods.AsNoTracking().Where(x => x.SubjectId == student.SubjectId && x.UniversityId == student.UniversityId
            && x.Day >= from && x.Day <= to).OrderBy(x => x.Day).ToListAsync(ct);

    public Task<DailyMood?> FindMoodAsync(CurrentStudent student, DateOnly day, CancellationToken ct) =>
        db.DailyMoods.SingleOrDefaultAsync(x => x.SubjectId == student.SubjectId && x.UniversityId == student.UniversityId && x.Day == day, ct);

    public async Task SaveMoodAsync(DailyMood mood, bool isNew, ActivityAuditEvent audit, CancellationToken ct)
    {
        if (isNew) db.DailyMoods.Add(mood);
        db.ActivityAuditEvents.Add(audit);
        await db.SaveChangesAsync(ct);
    }

    public async Task DeleteMoodAsync(DailyMood mood, ActivityAuditEvent audit, CancellationToken ct)
    {
        db.DailyMoods.Remove(mood);
        db.ActivityAuditEvents.Add(audit);
        await db.SaveChangesAsync(ct);
    }
}

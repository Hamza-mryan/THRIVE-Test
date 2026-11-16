using Microsoft.EntityFrameworkCore;
using Thrive.Application.Catalog;
using Thrive.Application.Identity;
using Thrive.Application.Referrals;
using Thrive.Application.Screening;
using Thrive.Domain.Catalog;
using Thrive.Domain.Referrals;
using Thrive.Domain.Screening;
using Thrive.Domain.Activity;

namespace Thrive.Infrastructure.Persistence;

public sealed class EfScreeningStore(ThriveDbContext db) : IScreeningStore
{
    public Task<ScreeningSession?> FindAsync(CurrentStudent student, Guid id, CancellationToken ct) =>
        db.ScreeningSessions.Include(x => x.Answers).SingleOrDefaultAsync(x => x.Id == id && x.SubjectId == student.SubjectId && x.UniversityId == student.UniversityId, ct);
    public async Task<IReadOnlyList<ScreeningSession>> ListAsync(CurrentStudent student, CancellationToken ct) =>
        await db.ScreeningSessions.AsNoTracking().Include(x => x.Answers).Where(x => x.SubjectId == student.SubjectId && x.UniversityId == student.UniversityId).OrderByDescending(x => x.StartedAtUtc).ToListAsync(ct);
    public async Task AddAsync(ScreeningSession session, CancellationToken ct)
    {
        db.ScreeningSessions.Add(session);
        db.ActivityAuditEvents.Add(Audit(session, "screening.started", session.StartedAtUtc));
        await db.SaveChangesAsync(ct);
    }
    public Task SaveAsync(ScreeningSession session, string action, DateTimeOffset occurredAtUtc, CancellationToken ct)
    {
        db.ActivityAuditEvents.Add(Audit(session, action, occurredAtUtc));
        return db.SaveChangesAsync(ct);
    }
    private static ActivityAuditEvent Audit(ScreeningSession session, string action, DateTimeOffset timestamp) => new()
    {
        SubjectId = session.SubjectId,
        UniversityId = session.UniversityId,
        Action = action,
        ResourceId = session.Id.ToString(),
        OccurredAtUtc = timestamp
    };
}

public sealed class EfCatalogStore(ThriveDbContext db) : ICatalogStore
{
    public async Task<IReadOnlyList<UniversityService>> ServicesAsync(string university, CancellationToken ct) => await db.UniversityServices.AsNoTracking().Where(x => x.UniversityId == university).OrderBy(x => x.NameEn).ToListAsync(ct);
    public async Task<IReadOnlyList<GuideResource>> ResourcesAsync(string university, CancellationToken ct) => await db.GuideResources.AsNoTracking().Where(x => x.UniversityId == university).OrderBy(x => x.TitleEn).ToListAsync(ct);
    public Task<UniversityService?> ServiceAsync(string university, Guid id, CancellationToken ct) => db.UniversityServices.SingleOrDefaultAsync(x => x.Id == id && x.UniversityId == university, ct);
    public Task<GuideResource?> ResourceAsync(string university, Guid id, CancellationToken ct) => db.GuideResources.SingleOrDefaultAsync(x => x.Id == id && x.UniversityId == university, ct);
    public async Task AddServiceAsync(UniversityService service, CancellationToken ct)
    {
        db.UniversityServices.Add(service);
        await db.SaveChangesAsync(ct);
    }
    public async Task AddResourceAsync(GuideResource resource, CancellationToken ct)
    {
        db.GuideResources.Add(resource);
        await db.SaveChangesAsync(ct);
    }
    public Task SaveAsync(CancellationToken ct) => db.SaveChangesAsync(ct);
    public Task SeedDemoAsync(string university, CancellationToken ct) => DemoCatalogSeeder.SeedAsync(db, university, ct);
}

public sealed class EfReferralStore(ThriveDbContext db) : IReferralStore
{
    public async Task<IReadOnlyList<Referral>> ListAsync(string university, string? subject, CancellationToken ct) => await db.Referrals.AsNoTracking().Where(x => x.UniversityId == university && (subject == null || x.SubjectId == subject)).OrderByDescending(x => x.CreatedAtUtc).ToListAsync(ct);
    public Task<Referral?> FindAsync(string university, string? subject, Guid id, CancellationToken ct) => db.Referrals.Include(x => x.Events).SingleOrDefaultAsync(x => x.Id == id && x.UniversityId == university && (subject == null || x.SubjectId == subject), ct);
    public async Task AddAsync(Referral referral, CancellationToken ct)
    {
        db.Referrals.Add(referral);
        await db.SaveChangesAsync(ct);
    }
    public Task SaveAsync(ReferralStatusEvent statusEvent, CancellationToken ct)
    {
        db.Set<ReferralStatusEvent>().Add(statusEvent);
        return db.SaveChangesAsync(ct);
    }
    public async Task<(int Screenings, int Referrals, int Completed)> CountsAsync(string university, CancellationToken ct) =>
        (await db.ScreeningSessions.CountAsync(x => x.UniversityId == university && x.CompletedAtUtc != null, ct), await db.Referrals.CountAsync(x => x.UniversityId == university, ct), await db.Referrals.CountAsync(x => x.UniversityId == university && x.Status == "Completed", ct));
}

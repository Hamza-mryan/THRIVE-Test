using Microsoft.EntityFrameworkCore;
using Thrive.Application.Consent;
using Thrive.Application.Identity;
using Thrive.Domain.Consent;

namespace Thrive.Infrastructure.Persistence;

public sealed class EfConsentStore(ThriveDbContext db) : IConsentStore
{
    public Task<ConsentDecision?> GetLatestAsync(CurrentStudent student, CancellationToken cancellationToken) =>
        db.ConsentDecisions.AsNoTracking()
            .Where(x => x.SubjectId == student.SubjectId && x.UniversityId == student.UniversityId)
            .OrderByDescending(x => x.RecordedAtUtc).ThenByDescending(x => x.Id)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task SaveAsync(ConsentDecision decision, CancellationToken cancellationToken)
    {
        db.ConsentDecisions.Add(decision);
        db.ConsentAuditEvents.Add(ConsentAuditEvent.ForDecision(decision));
        // Both append-only records commit in the same database transaction.
        await db.SaveChangesAsync(cancellationToken);
    }
}

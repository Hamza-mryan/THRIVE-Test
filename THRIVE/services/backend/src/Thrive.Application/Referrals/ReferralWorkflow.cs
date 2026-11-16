using Thrive.Application.Catalog;
using Thrive.Application.Features;
using Thrive.Application.Identity;
using Thrive.Domain.Referrals;
using Thrive.Domain;

namespace Thrive.Application.Referrals;

public interface IReferralStore
{
    Task<IReadOnlyList<Referral>> ListAsync(string university, string? subject, CancellationToken ct);
    Task<Referral?> FindAsync(string university, string? subject, Guid id, CancellationToken ct);
    Task AddAsync(Referral referral, CancellationToken ct);
    Task SaveAsync(ReferralStatusEvent statusEvent, CancellationToken ct);
    Task<(int Screenings, int Referrals, int Completed)> CountsAsync(string university, CancellationToken ct);
}

public sealed class ReferralWorkflow(IReferralStore store, CatalogWorkflow catalog, TimeProvider clock)
{
    public Task<IReadOnlyList<Referral>> ListAsync(CurrentStudent student, bool admin, CancellationToken ct) => store.ListAsync(student.UniversityId, admin ? null : student.SubjectId, ct);
    public async Task<Referral> RequestAsync(CurrentStudent student, Guid serviceId, bool shareConsent, bool demo, CancellationToken ct)
    {
        FeatureValidation.Require(shareConsent, "Consent to share the minimum referral information is required.");
        var service = await catalog.ServiceAsync(student.UniversityId, serviceId, ct);
        if (!service.Active || !(service.Verified && !service.IsDemo || demo && service.IsDemo)) throw new FeatureException(404, "Service is unavailable.");
        if ((await store.ListAsync(student.UniversityId, student.SubjectId, ct)).Any(x => x.ServiceId == serviceId && Referral.IsOpen(x.Status))) throw new FeatureException(409, "An open referral to this service already exists.");
        var now = UtcTimestamp.Normalize(clock.GetUtcNow());
        var referral = new Referral { SubjectId = student.SubjectId, UniversityId = student.UniversityId, ServiceId = service.Id, ServiceNameAr = service.NameAr, ServiceNameEn = service.NameEn, Level = service.Level, IsDemo = service.IsDemo, CreatedAtUtc = now, UpdatedAtUtc = now };
        referral.Events.Add(new ReferralStatusEvent { ReferralId = referral.Id, ActorSubjectId = student.SubjectId, Status = referral.Status, OccurredAtUtc = referral.CreatedAtUtc });
        await store.AddAsync(referral, ct);
        return referral;
    }
    public async Task<Referral> TransitionAsync(CurrentStudent student, Guid id, string status, bool admin, CancellationToken ct)
    {
        var referral = await store.FindAsync(student.UniversityId, admin ? null : student.SubjectId, id, ct) ?? throw new FeatureException(404, "Referral not found.");
        if (!Referral.CanTransition(referral.Status, status, !admin)) throw new FeatureException(409, "Invalid referral status transition.");
        if (referral.Status != status)
        {
            referral.Status = status;
            referral.UpdatedAtUtc = UtcTimestamp.Normalize(clock.GetUtcNow());
            var statusEvent = new ReferralStatusEvent { ReferralId = referral.Id, ActorSubjectId = student.SubjectId, Status = status, OccurredAtUtc = referral.UpdatedAtUtc };
            referral.Events.Add(statusEvent);
            await store.SaveAsync(statusEvent, ct);
        }
        return referral;
    }
    public Task<(int Screenings, int Referrals, int Completed)> CountsAsync(string university, CancellationToken ct) => store.CountsAsync(university, ct);
}

using Thrive.Application.Identity;
using Thrive.Domain.Consent;

namespace Thrive.Application.Consent;

public sealed class ConsentService(IConsentStore store, TimeProvider timeProvider)
{
    public async Task<ConsentDecision> WithdrawAsync(CurrentStudent student, CancellationToken ct)
    {
        var latest = await store.GetLatestAsync(student, ct);
        if (latest is not null && !latest.ServiceUse && !latest.ResearchUse) return latest;
        var decision = ConsentDecision.Withdraw(student.SubjectId, student.UniversityId, ConsentPolicy.Current.Version, timeProvider.GetUtcNow());
        await store.SaveAsync(decision, ct);
        return decision;
    }
    public Task<ConsentDecision?> GetCurrentAsync(CurrentStudent student, CancellationToken cancellationToken) =>
        store.GetLatestAsync(student, cancellationToken);

    public async Task<ConsentDecision> RecordAsync(
        CurrentStudent student, string policyVersion, bool serviceUse, bool researchUse,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(policyVersion, ConsentPolicy.Current.Version, StringComparison.Ordinal))
            throw new ConsentValidationException("policyVersion", "Refresh and accept the current policy version.");
        if (!serviceUse)
            throw new ConsentValidationException("serviceUse", "Service consent is required to finish onboarding. Research consent remains optional.");

        var latest = await store.GetLatestAsync(student, cancellationToken);
        if (latest is not null && latest.PolicyVersion == policyVersion
            && latest.ServiceUse == serviceUse && latest.ResearchUse == researchUse)
            return latest;

        var decision = ConsentDecision.Record(student.SubjectId, student.UniversityId,
            policyVersion, serviceUse, researchUse, timeProvider.GetUtcNow());
        await store.SaveAsync(decision, cancellationToken);
        return decision;
    }
}

public sealed class ConsentValidationException(string field, string message) : Exception(message)
{
    public string Field { get; } = field;
}

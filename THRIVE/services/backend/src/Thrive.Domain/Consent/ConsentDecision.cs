namespace Thrive.Domain.Consent;

public sealed class ConsentDecision
{
    private ConsentDecision() { }

    public Guid Id { get; private set; }
    public string SubjectId { get; private set; } = string.Empty;
    public string UniversityId { get; private set; } = string.Empty;
    public string PolicyVersion { get; private set; } = string.Empty;
    public bool ServiceUse { get; private set; }
    public bool ResearchUse { get; private set; }
    public DateTimeOffset RecordedAtUtc { get; private set; }

    public static ConsentDecision Record(
        string subjectId, string universityId, string policyVersion,
        bool serviceUse, bool researchUse, DateTimeOffset recordedAtUtc)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(subjectId);
        ArgumentException.ThrowIfNullOrWhiteSpace(universityId);
        ArgumentException.ThrowIfNullOrWhiteSpace(policyVersion);
        if (!serviceUse)
            throw new ArgumentException("Service consent is required for onboarding.", nameof(serviceUse));

        return new ConsentDecision
        {
            Id = Guid.NewGuid(),
            SubjectId = subjectId,
            UniversityId = universityId,
            PolicyVersion = policyVersion,
            ServiceUse = serviceUse,
            ResearchUse = researchUse,
            RecordedAtUtc = UtcTimestamp.Normalize(recordedAtUtc)
        };
    }

    public static ConsentDecision Withdraw(string subjectId, string universityId, string policyVersion, DateTimeOffset recordedAtUtc)
    {
        var decision = Record(subjectId, universityId, policyVersion, true, false, recordedAtUtc);
        decision.ServiceUse = false;
        return decision;
    }
}

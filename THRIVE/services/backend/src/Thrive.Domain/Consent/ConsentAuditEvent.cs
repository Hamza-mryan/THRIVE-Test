namespace Thrive.Domain.Consent;

// Records the operation, without copying consent text, answers, scores, or tokens.
public sealed class ConsentAuditEvent
{
    private ConsentAuditEvent() { }

    public Guid Id { get; private set; }
    public Guid DecisionId { get; private set; }
    public string SubjectId { get; private set; } = string.Empty;
    public string UniversityId { get; private set; } = string.Empty;
    public string Action { get; private set; } = "consent.recorded";
    public DateTimeOffset OccurredAtUtc { get; private set; }

    public static ConsentAuditEvent ForDecision(ConsentDecision decision) => new()
    {
        Id = Guid.NewGuid(),
        DecisionId = decision.Id,
        SubjectId = decision.SubjectId,
        UniversityId = decision.UniversityId,
        Action = decision.ServiceUse ? "consent.recorded" : "consent.withdrawn",
        OccurredAtUtc = decision.RecordedAtUtc
    };
}

namespace Thrive.Domain.Activity;

// Voluntary self-report, never a screening score or a clinical risk trigger.
public sealed class DailyMood
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string SubjectId { get; set; } = "";
    public string UniversityId { get; set; } = "";
    public DateOnly Day { get; set; }
    public int Value { get; set; }
    public DateTimeOffset UpdatedAtUtc { get; set; }
}

public sealed class ActivityAuditEvent
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string SubjectId { get; set; } = "";
    public string UniversityId { get; set; } = "";
    public string Action { get; set; } = "";
    public string ResourceId { get; set; } = "";
    public DateTimeOffset OccurredAtUtc { get; set; }
}

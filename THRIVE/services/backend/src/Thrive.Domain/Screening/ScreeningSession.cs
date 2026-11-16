namespace Thrive.Domain.Screening;

public sealed class ScreeningSession
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string SubjectId { get; set; } = "";
    public string UniversityId { get; set; } = "";
    public string InstrumentCode { get; set; } = "";
    public string InstrumentVersion { get; set; } = "";
    public DateTimeOffset StartedAtUtc { get; set; }
    public DateTimeOffset? CompletedAtUtc { get; set; }
    public int? RawScore { get; set; }
    public int Revision { get; set; }
    public List<ScreeningAnswer> Answers { get; set; } = [];
}

public sealed class ScreeningAnswer
{
    public Guid SessionId { get; set; }
    public string ItemCode { get; set; } = "";
    public int Value { get; set; }
}

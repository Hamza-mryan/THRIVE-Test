namespace Thrive.Domain.Referrals;

public sealed class Referral
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string SubjectId { get; set; } = "";
    public string UniversityId { get; set; } = "";
    public Guid ServiceId { get; set; }
    public string ServiceNameAr { get; set; } = "";
    public string ServiceNameEn { get; set; } = "";
    public string Level { get; set; } = "";
    public string Status { get; set; } = "Requested";
    public DateTimeOffset CreatedAtUtc { get; set; }
    public DateTimeOffset UpdatedAtUtc { get; set; }
    public bool IsDemo { get; set; }
    public List<ReferralStatusEvent> Events { get; set; } = [];

    public static bool IsOpen(string status) => status is "Requested" or "Received" or "Scheduled";

    public static bool CanTransition(string from, string to, bool student) =>
        from == to || (student
            ? IsOpen(from) && to == "Cancelled"
            : (from, to) is ("Requested", "Received" or "Declined")
                or ("Received", "Scheduled" or "Declined")
                or ("Scheduled", "Completed" or "Declined"));
}

public sealed class ReferralStatusEvent
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ReferralId { get; set; }
    public string ActorSubjectId { get; set; } = "";
    public string Status { get; set; } = "";
    public DateTimeOffset OccurredAtUtc { get; set; }
}

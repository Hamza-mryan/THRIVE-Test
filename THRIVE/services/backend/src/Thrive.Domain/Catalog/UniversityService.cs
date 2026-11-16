namespace Thrive.Domain.Catalog;

public sealed class UniversityService
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string UniversityId { get; set; } = "";
    public string Level { get; set; } = "Counseling";
    public string NameAr { get; set; } = "";
    public string NameEn { get; set; } = "";
    public string DescriptionAr { get; set; } = "";
    public string DescriptionEn { get; set; } = "";
    public string HoursAr { get; set; } = "";
    public string HoursEn { get; set; } = "";
    public string LocationAr { get; set; } = "";
    public string LocationEn { get; set; } = "";
    public string BookingMethod { get; set; } = "";
    public string? ContactUrl { get; set; }
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public string? Specialty { get; set; }
    public string? Source { get; set; }
    public bool IsDemo { get; set; }
    public bool Verified { get; set; }
    public bool Active { get; set; }
}

namespace Thrive.Domain.Catalog;

public sealed class GuideResource
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string UniversityId { get; set; } = "";
    public string Slug { get; set; } = "";
    public string TitleAr { get; set; } = "";
    public string TitleEn { get; set; } = "";
    public string SummaryAr { get; set; } = "";
    public string SummaryEn { get; set; } = "";
    public string BodyAr { get; set; } = "";
    public string BodyEn { get; set; } = "";
    public string Category { get; set; } = "";
    public string Source { get; set; } = "";
    public DateTimeOffset? ReviewedAtUtc { get; set; }
    public string Version { get; set; } = "1";
    public bool IsDemo { get; set; }
    public bool Published { get; set; }
}

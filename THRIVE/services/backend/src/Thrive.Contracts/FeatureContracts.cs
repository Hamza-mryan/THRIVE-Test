namespace Thrive.Contracts;

public sealed record StartSessionRequest(string InstrumentCode);
public sealed record AnswerRequest(int Value);
public sealed record AnswerResponse(string ItemCode, int Value);
public sealed record ScreeningResultResponse(Guid SessionId, string InstrumentCode, string State, int RawScore, int MaxScore, string RuleVersion, string ReasonAr, string ReasonEn, DateTimeOffset CreatedAtUtc, bool IsDemo);
public sealed record SessionResponse(Guid Id, string InstrumentCode, string InstrumentVersion, string Status, DateTimeOffset StartedAtUtc, DateTimeOffset? CompletedAtUtc, AnswerResponse[] Answers, ScreeningResultResponse? Result);
public sealed record ServiceResponse(Guid Id, string Level, string NameAr, string NameEn, string DescriptionAr, string DescriptionEn, string HoursAr, string HoursEn, string LocationAr, string LocationEn, string BookingMethod, string? ContactUrl, bool IsDemo, bool Verified, bool Active, string? Phone = null, string? Email = null, string? Specialty = null, string? Source = null);
public sealed record ResourceResponse(Guid Id, string Slug, string TitleAr, string TitleEn, string SummaryAr, string SummaryEn, string BodyAr, string BodyEn, string Category, string Source, DateTimeOffset? ReviewedAtUtc, string Version, bool IsDemo, bool Published);
public sealed record ReferralRequest(Guid ServiceId, bool ShareConsent);
public sealed record ReferralResponse(Guid Id, Guid ServiceId, string ServiceNameAr, string ServiceNameEn, string Level, string Status, DateTimeOffset CreatedAtUtc, DateTimeOffset UpdatedAtUtc, bool IsDemo);
public sealed record ReferralStatusRequest(string Status);
public sealed record ServiceWrite(string Level, string NameAr, string NameEn, string DescriptionAr, string DescriptionEn, string HoursAr, string HoursEn, string LocationAr, string LocationEn, string BookingMethod, string? ContactUrl, bool Verified, bool Active, string? Phone = null, string? Email = null, string? Specialty = null, string? Source = null);
public sealed record ResourceWrite(string Slug, string TitleAr, string TitleEn, string SummaryAr, string SummaryEn, string BodyAr, string BodyEn, string Category, string Source, string Version, bool Published);
public sealed record AggregateReportResponse(int? ScreeningsCount, int? ReferralsCount, int? CompletedReferralsCount, int MinCellSize, int AvailableResourcesCount, int AvailableServicesCount);

namespace Thrive.Contracts;

public sealed record ActivitySummaryResponse(int CompletedScreenings, int InProgressScreenings, int OpenReferrals, DateTimeOffset? LatestScreeningAtUtc);
public sealed record MoodRequest(int Value);
public sealed record MoodResponse(DateOnly Day, int Value, DateTimeOffset UpdatedAtUtc);

namespace Thrive.Domain;

/// <summary>Shared UTC timestamp precision for stable persisted API responses.</summary>
public static class UtcTimestamp
{
    public static DateTimeOffset Normalize(DateTimeOffset value)
    {
        var utcTicks = value.UtcTicks;
        return new DateTimeOffset(utcTicks - utcTicks % 10, TimeSpan.Zero);
    }
}

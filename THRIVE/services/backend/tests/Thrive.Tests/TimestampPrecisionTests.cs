using Thrive.Domain;

namespace Thrive.Tests;

public sealed class TimestampPrecisionTests
{
    [Fact]
    public void ResponsesUseUtcMicrosecondPrecisionBeforeAndAfterPersistence()
    {
        var source = new DateTimeOffset(2026, 11, 4, 8, 35, 12, TimeSpan.FromHours(3)).AddTicks(2272577);
        var normalized = UtcTimestamp.Normalize(source);
        Assert.Equal(TimeSpan.Zero, normalized.Offset);
        Assert.Equal(0, normalized.Ticks % 10);
        Assert.InRange(source.UtcTicks - normalized.UtcTicks, 0, 9);
        Assert.Equal(normalized, UtcTimestamp.Normalize(normalized));
    }
}

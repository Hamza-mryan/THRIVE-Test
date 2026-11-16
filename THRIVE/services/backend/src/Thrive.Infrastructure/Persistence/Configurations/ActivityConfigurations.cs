using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Thrive.Domain.Activity;

namespace Thrive.Infrastructure.Persistence.Configurations;

public sealed class DailyMoodConfiguration : IEntityTypeConfiguration<DailyMood>
{
    public void Configure(EntityTypeBuilder<DailyMood> b)
    {
        b.ToTable("daily_moods");
        b.HasKey(x => x.Id);
        b.Property(x => x.SubjectId).HasMaxLength(200);
        b.Property(x => x.UniversityId).HasMaxLength(100);
        b.HasIndex(x => new { x.UniversityId, x.SubjectId, x.Day }).IsUnique();
        b.Property(x => x.UpdatedAtUtc).HasConversion(x => x.UtcDateTime, x => new DateTimeOffset(DateTime.SpecifyKind(x, DateTimeKind.Utc)));
    }
}

public sealed class ActivityAuditConfiguration : IEntityTypeConfiguration<ActivityAuditEvent>
{
    public void Configure(EntityTypeBuilder<ActivityAuditEvent> b)
    {
        b.ToTable("activity_audit_events");
        b.HasKey(x => x.Id);
        b.Property(x => x.SubjectId).HasMaxLength(200);
        b.Property(x => x.UniversityId).HasMaxLength(100);
        b.Property(x => x.Action).HasMaxLength(80);
        b.Property(x => x.ResourceId).HasMaxLength(100);
        b.Property(x => x.OccurredAtUtc).HasConversion(x => x.UtcDateTime, x => new DateTimeOffset(DateTime.SpecifyKind(x, DateTimeKind.Utc)));
    }
}

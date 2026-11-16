using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Thrive.Domain.Catalog;
using Thrive.Domain.Referrals;
using Thrive.Domain.Screening;

namespace Thrive.Infrastructure.Persistence.Configurations;

public sealed class ScreeningConfiguration : IEntityTypeConfiguration<ScreeningSession>
{
    public void Configure(EntityTypeBuilder<ScreeningSession> b)
    {
        b.ToTable("screening_sessions");
        b.HasKey(x => x.Id);
        b.Property(x => x.SubjectId).HasMaxLength(200);
        b.Property(x => x.UniversityId).HasMaxLength(100);
        b.Property(x => x.InstrumentCode).HasMaxLength(80);
        b.Property(x => x.InstrumentVersion).HasMaxLength(80);
        b.Property(x => x.Revision).IsConcurrencyToken();
        b.Property(x => x.StartedAtUtc).HasConversion(x => x.UtcDateTime, x => new DateTimeOffset(DateTime.SpecifyKind(x, DateTimeKind.Utc)));
        b.Property(x => x.CompletedAtUtc).HasConversion(x => x.HasValue ? x.Value.UtcDateTime : (DateTime?)null, x => x.HasValue ? new DateTimeOffset(DateTime.SpecifyKind(x.Value, DateTimeKind.Utc)) : null);
        b.HasIndex(x => new { x.UniversityId, x.SubjectId, x.StartedAtUtc });
        b.HasMany(x => x.Answers).WithOne().HasForeignKey(x => x.SessionId).OnDelete(DeleteBehavior.Cascade);
    }
}
public sealed class AnswerConfiguration : IEntityTypeConfiguration<ScreeningAnswer>
{
    public void Configure(EntityTypeBuilder<ScreeningAnswer> b)
    {
        b.ToTable("screening_answers");
        b.HasKey(x => new { x.SessionId, x.ItemCode });
        b.Property(x => x.ItemCode).HasMaxLength(80);
    }
}
public sealed class ServiceConfiguration : IEntityTypeConfiguration<UniversityService>
{
    public void Configure(EntityTypeBuilder<UniversityService> b)
    {
        b.ToTable("university_services");
        b.HasKey(x => x.Id);
        b.Property(x => x.UniversityId).HasMaxLength(100);
        b.Property(x => x.Phone).HasMaxLength(32);
        b.Property(x => x.Email).HasMaxLength(254);
        b.Property(x => x.Specialty).HasMaxLength(40);
        b.Property(x => x.Source).HasMaxLength(500);
        b.HasIndex(x => x.UniversityId);
    }
}
public sealed class ResourceConfiguration : IEntityTypeConfiguration<GuideResource>
{
    public void Configure(EntityTypeBuilder<GuideResource> b)
    {
        b.ToTable("guide_resources");
        b.HasKey(x => x.Id);
        b.Property(x => x.UniversityId).HasMaxLength(100);
        b.Property(x => x.Slug).HasMaxLength(100);
        b.HasIndex(x => new { x.UniversityId, x.Slug }).IsUnique();
        b.Property(x => x.ReviewedAtUtc).HasConversion(x => x.HasValue ? x.Value.UtcDateTime : (DateTime?)null, x => x.HasValue ? new DateTimeOffset(DateTime.SpecifyKind(x.Value, DateTimeKind.Utc)) : null);
    }
}
public sealed class ReferralConfiguration : IEntityTypeConfiguration<Referral>
{
    public void Configure(EntityTypeBuilder<Referral> b)
    {
        b.ToTable("referrals");
        b.HasKey(x => x.Id);
        b.Property(x => x.SubjectId).HasMaxLength(200);
        b.Property(x => x.UniversityId).HasMaxLength(100);
        b.Property(x => x.Status).HasMaxLength(40).IsConcurrencyToken();
        b.Property(x => x.CreatedAtUtc).HasConversion(x => x.UtcDateTime, x => new DateTimeOffset(DateTime.SpecifyKind(x, DateTimeKind.Utc)));
        b.Property(x => x.UpdatedAtUtc).HasConversion(x => x.UtcDateTime, x => new DateTimeOffset(DateTime.SpecifyKind(x, DateTimeKind.Utc)));
        b.HasIndex(x => new { x.UniversityId, x.SubjectId, x.ServiceId }).IsUnique().HasFilter("\"Status\" IN ('Requested', 'Received', 'Scheduled')");
        b.HasOne<UniversityService>().WithMany().HasForeignKey(x => x.ServiceId).OnDelete(DeleteBehavior.Restrict);
        b.HasMany(x => x.Events).WithOne().HasForeignKey(x => x.ReferralId).OnDelete(DeleteBehavior.Restrict);
    }
}
public sealed class ReferralEventConfiguration : IEntityTypeConfiguration<ReferralStatusEvent>
{
    public void Configure(EntityTypeBuilder<ReferralStatusEvent> b)
    {
        b.ToTable("referral_status_events");
        b.HasKey(x => x.Id);
        b.Property(x => x.ActorSubjectId).HasMaxLength(200);
        b.Property(x => x.Status).HasMaxLength(40);
        b.Property(x => x.OccurredAtUtc).HasConversion(x => x.UtcDateTime, x => new DateTimeOffset(DateTime.SpecifyKind(x, DateTimeKind.Utc)));
    }
}

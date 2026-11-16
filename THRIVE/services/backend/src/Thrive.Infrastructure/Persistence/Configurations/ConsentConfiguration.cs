using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Thrive.Domain.Consent;

namespace Thrive.Infrastructure.Persistence.Configurations;

public sealed class ConsentConfiguration : IEntityTypeConfiguration<ConsentDecision>
{
    public void Configure(EntityTypeBuilder<ConsentDecision> builder)
    {
        builder.ToTable("consent_decisions");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.SubjectId).HasMaxLength(200);
        builder.Property(x => x.UniversityId).HasMaxLength(100);
        builder.Property(x => x.PolicyVersion).HasMaxLength(80);
        builder.Property(x => x.RecordedAtUtc).HasConversion(
            value => value.UtcDateTime,
            value => new DateTimeOffset(DateTime.SpecifyKind(value, DateTimeKind.Utc)));
        builder.HasIndex(x => new { x.UniversityId, x.SubjectId, x.RecordedAtUtc });
    }
}

public sealed class ConsentAuditConfiguration : IEntityTypeConfiguration<ConsentAuditEvent>
{
    public void Configure(EntityTypeBuilder<ConsentAuditEvent> builder)
    {
        builder.ToTable("consent_audit_events");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.SubjectId).HasMaxLength(200);
        builder.Property(x => x.UniversityId).HasMaxLength(100);
        builder.Property(x => x.Action).HasMaxLength(80);
        builder.Property(x => x.OccurredAtUtc).HasConversion(
            value => value.UtcDateTime,
            value => new DateTimeOffset(DateTime.SpecifyKind(value, DateTimeKind.Utc)));
        builder.HasOne<ConsentDecision>().WithMany().HasForeignKey(x => x.DecisionId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

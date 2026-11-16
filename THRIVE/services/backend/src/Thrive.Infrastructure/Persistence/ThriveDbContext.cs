using Microsoft.EntityFrameworkCore;
using Thrive.Domain.Consent;
using Thrive.Domain.Catalog;
using Thrive.Domain.Referrals;
using Thrive.Domain.Screening;
using Thrive.Domain.Activity;

namespace Thrive.Infrastructure.Persistence;

public sealed class ThriveDbContext(DbContextOptions<ThriveDbContext> options) : DbContext(options)
{
    public DbSet<ConsentDecision> ConsentDecisions => Set<ConsentDecision>();
    public DbSet<ConsentAuditEvent> ConsentAuditEvents => Set<ConsentAuditEvent>();
    public DbSet<ScreeningSession> ScreeningSessions => Set<ScreeningSession>();
    public DbSet<UniversityService> UniversityServices => Set<UniversityService>();
    public DbSet<GuideResource> GuideResources => Set<GuideResource>();
    public DbSet<Referral> Referrals => Set<Referral>();
    public DbSet<DailyMood> DailyMoods => Set<DailyMood>();
    public DbSet<ActivityAuditEvent> ActivityAuditEvents => Set<ActivityAuditEvent>();

    protected override void OnModelCreating(ModelBuilder modelBuilder) =>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ThriveDbContext).Assembly);
}

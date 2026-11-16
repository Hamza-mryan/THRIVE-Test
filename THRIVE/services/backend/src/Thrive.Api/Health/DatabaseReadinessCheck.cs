using Microsoft.Extensions.Diagnostics.HealthChecks;
using Thrive.Infrastructure.Persistence;

namespace Thrive.Api.Health;

public sealed class DatabaseReadinessCheck(IServiceScopeFactory scopeFactory, IConfiguration configuration) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(configuration.GetConnectionString("Thrive")))
            return HealthCheckResult.Unhealthy("Database is not configured.");
        try
        {
            using var scope = scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ThriveDbContext>();
            if (!await db.Database.CanConnectAsync(cancellationToken))
                return HealthCheckResult.Unhealthy("Database is unavailable.");
            var pending = await Microsoft.EntityFrameworkCore.RelationalDatabaseFacadeExtensions
                .GetPendingMigrationsAsync(db.Database, cancellationToken);
            return pending.Any()
                ? HealthCheckResult.Unhealthy("Database migrations are pending.")
                : HealthCheckResult.Healthy();
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            // Health output deliberately omits provider exceptions and connection details.
            return HealthCheckResult.Unhealthy("Database readiness check failed.");
        }
    }
}

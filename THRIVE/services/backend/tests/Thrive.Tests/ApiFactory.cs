using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Thrive.Infrastructure.Persistence;

namespace Thrive.Tests;

public sealed class ApiFactory(bool developmentIdentity = true, string environment = "Development")
    : WebApplicationFactory<Program>
{
    private readonly SqliteConnection _connection = new("Data Source=:memory:");

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        _connection.Open();
        builder.UseEnvironment(environment);
        builder.UseSetting("DevelopmentIdentity:Enabled", developmentIdentity.ToString());
        builder.ConfigureAppConfiguration((_, configuration) => configuration.AddInMemoryCollection(
            new Dictionary<string, string?>
            {
                ["DevelopmentIdentity:Enabled"] = developmentIdentity.ToString(),
                ["ConnectionStrings:Thrive"] = null,
                ["Identity:Authority"] = "",
                ["Identity:Audience"] = ""
            }));
        builder.ConfigureTestServices(services =>
        {
            services.RemoveAll<DbContextOptions<ThriveDbContext>>();
            services.RemoveAll<IDbContextOptionsConfiguration<ThriveDbContext>>();
            services.AddDbContext<ThriveDbContext>(options => options.UseSqlite(_connection));
        });
    }

    public HttpClient CreateInitializedClient()
    {
        var client = CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost") });
        using var scope = Services.CreateScope();
        scope.ServiceProvider.GetRequiredService<ThriveDbContext>().Database.EnsureCreated();
        return client;
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (disposing)
            _connection.Dispose();
    }
}

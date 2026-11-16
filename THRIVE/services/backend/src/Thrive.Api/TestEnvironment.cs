using Npgsql;

namespace Thrive.Api;

/// <summary>Fail before opening a connection if this copy targets a shared database.</summary>
public static class TestEnvironment
{
    public static string RequireDatabase(string? connectionString)
    {
        connectionString = string.IsNullOrWhiteSpace(connectionString)
            ? "Host=127.0.0.1;Port=55432;Database=thrive_test;Username=thrive_test_local;Timeout=2;Include Error Detail=false"
            : connectionString;
        NpgsqlConnectionStringBuilder settings;
        try
        {
            settings = new NpgsqlConnectionStringBuilder(connectionString);
        }
        catch (ArgumentException)
        {
            throw new InvalidOperationException("THRIVE Test requires a valid isolated local database configuration.");
        }
        if (settings.Host is not ("localhost" or "127.0.0.1")
            || settings.Port != 55432 || settings.Database != "thrive_test"
            || settings.Username != "thrive_test_local" || settings.IncludeErrorDetail)
            throw new InvalidOperationException("THRIVE Test refuses a shared or remote database. Use scripts/start-backend.ps1.");
        return connectionString;
    }
}

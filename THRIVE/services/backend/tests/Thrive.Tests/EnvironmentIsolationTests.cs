using Thrive.Api;

namespace Thrive.Tests;

public sealed class EnvironmentIsolationTests
{
    [Theory]
    [InlineData("Host=localhost;Port=5432;Database=thrive_development;Username=thrive_local")]
    [InlineData("Host=production.example;Port=55432;Database=thrive_test;Username=thrive_test_local")]
    [InlineData("Host=127.0.0.1;Port=55432;Database=thrive_development;Username=thrive_test_local")]
    [InlineData("Host=127.0.0.1;Port=55432;Database=thrive_test;Username=thrive_local")]
    [InlineData("Host=localhost,production.example;Port=55432;Database=thrive_test;Username=thrive_test_local")]
    public void Shared_or_remote_database_is_rejected_before_connecting(string connectionString)
    {
        Assert.Throws<InvalidOperationException>(() => TestEnvironment.RequireDatabase(connectionString));
    }

    [Fact]
    public void Only_the_local_test_database_is_accepted()
    {
        const string connection = "Host=127.0.0.1;Port=55432;Database=thrive_test;Username=thrive_test_local";
        Assert.Equal(connection, TestEnvironment.RequireDatabase(connection));
    }

    [Fact]
    public void Unconfigured_connection_uses_only_the_test_endpoint()
    {
        var connection = TestEnvironment.RequireDatabase(null);
        Assert.Contains("Port=55432", connection);
        Assert.Contains("Database=thrive_test", connection);
    }
}

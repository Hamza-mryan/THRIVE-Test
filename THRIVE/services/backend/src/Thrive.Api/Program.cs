using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Thrive.Api.Endpoints;
using Thrive.Api.Health;
using Thrive.Api.Identity;
using Thrive.Api.OpenApi;
using Thrive.Application.Consent;
using Thrive.Infrastructure.Persistence;
using Thrive.Application.Catalog;
using Thrive.Application.Referrals;
using Thrive.Application.Screening;
using Thrive.Application.Activity;
using Thrive.Api;

var builder = WebApplication.CreateBuilder(args);
var testConnection = TestEnvironment.RequireDatabase(builder.Configuration.GetConnectionString("Thrive"));
if (!string.IsNullOrWhiteSpace(builder.Configuration["Identity:Authority"])
    || !string.IsNullOrWhiteSpace(builder.Configuration["Identity:Audience"]))
    throw new InvalidOperationException("THRIVE Test permits only isolated synthetic development identities.");
builder.Services.AddProblemDetails();
builder.Services.AddOpenApi(options => options.AddThriveAuthenticationMetadata());
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddScoped<ConsentService>();
builder.Services.AddScoped<IConsentStore, EfConsentStore>();
builder.Services.AddScoped<IScreeningStore, EfScreeningStore>();
builder.Services.AddScoped<ICatalogStore, EfCatalogStore>();
builder.Services.AddScoped<IReferralStore, EfReferralStore>();
builder.Services.AddScoped<ScreeningWorkflow>();
builder.Services.AddScoped<CatalogWorkflow>();
builder.Services.AddScoped<ReferralWorkflow>();
builder.Services.AddScoped<IStudentActivityStore, EfStudentActivityStore>();
builder.Services.AddScoped<StudentActivity>();
builder.Services.AddDbContext<ThriveDbContext>(options => options.UseNpgsql(testConnection));
builder.Services.AddHealthChecks().AddCheck<DatabaseReadinessCheck>("database", tags: ["ready"]);
builder.AddThriveIdentity();
builder.Services.AddCors(options => options.AddPolicy("local-frontends", policy =>
    policy.WithOrigins("http://localhost:5400", "http://localhost:4300")
        .WithHeaders("Content-Type", "Authorization").WithMethods("GET", "PUT", "POST", "DELETE", "OPTIONS")));

var app = builder.Build();
app.UseExceptionHandler();
app.UseStatusCodePages(async context =>
    await Results.Problem(statusCode: context.HttpContext.Response.StatusCode)
        .ExecuteAsync(context.HttpContext));
if (app.Environment.IsDevelopment())
{
    app.UseCors("local-frontends");
    app.MapOpenApi().AllowAnonymous();
    app.MapGet("/health/isolation", async (ThriveDbContext database, CancellationToken cancellationToken) =>
    {
        // Read the actual server identity before integration scripts are allowed to write.
        await database.Database.OpenConnectionAsync(cancellationToken);
        await using var command = database.Database.GetDbConnection().CreateCommand();
        command.CommandText = "SELECT current_database(), current_user, inet_server_port()";
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        await reader.ReadAsync(cancellationToken);
        return Results.Ok(new
        {
            application = "THRIVE Test",
            database = reader.GetString(0),
            databaseUser = reader.GetString(1),
            databasePort = new Npgsql.NpgsqlConnectionStringBuilder(testConnection).Port,
            serverPort = reader.GetInt32(2)
        });
    }).AllowAnonymous();
}
else
{
    app.UseHsts();
    app.UseHttpsRedirection();
}
app.UseAuthentication();
app.UseAuthorization();
app.MapGet("/health/live", () => Results.Ok(new { status = "ok" })).AllowAnonymous();
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = registration => registration.Tags.Contains("ready"),
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(new { status = report.Status.ToString() });
    }
}).AllowAnonymous();
app.MapIdentityEndpoints();
app.MapConsentEndpoints();
app.MapScreeningEndpoints();
app.MapCatalogEndpoints();
app.MapReferralEndpoints();
app.MapAdminEndpoints();
app.MapActivityEndpoints();
app.Run();

public partial class Program;

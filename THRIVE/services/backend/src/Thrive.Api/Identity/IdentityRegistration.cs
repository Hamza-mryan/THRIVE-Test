using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Thrive.Application.Identity;

namespace Thrive.Api.Identity;

public static class IdentityRegistration
{
    public const string StudentPolicy = "student";
    public const string AdminPolicy = "university-admin";

    public static void AddThriveIdentity(this WebApplicationBuilder builder)
    {
        var demoEnabled = builder.Environment.IsDevelopment()
            && builder.Configuration.GetValue<bool>("DevelopmentIdentity:Enabled");
        var authentication = builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme);
        if (demoEnabled)
        {
            var issuer = new DevelopmentTokenIssuer(TimeProvider.System);
            builder.Services.AddSingleton(issuer);
            authentication.AddJwtBearer(options =>
            {
                options.MapInboundClaims = false;
                options.IncludeErrorDetails = false;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = DevelopmentTokenIssuer.Issuer,
                    ValidateAudience = true,
                    ValidAudience = DevelopmentTokenIssuer.Audience,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = issuer.SigningKey,
                    ValidateLifetime = true,
                    RequireExpirationTime = true,
                    ClockSkew = TimeSpan.FromSeconds(15),
                    NameClaimType = "name",
                    RoleClaimType = "role"
                };
            });
        }
        else if (!string.IsNullOrWhiteSpace(builder.Configuration["Identity:Authority"])
                 && !string.IsNullOrWhiteSpace(builder.Configuration["Identity:Audience"]))
        {
            authentication.AddJwtBearer(options =>
            {
                options.Authority = builder.Configuration["Identity:Authority"];
                options.Audience = builder.Configuration["Identity:Audience"];
                options.RequireHttpsMetadata = true;
                options.MapInboundClaims = false;
                options.IncludeErrorDetails = false;
                options.TokenValidationParameters.NameClaimType = "name";
                options.TokenValidationParameters.RoleClaimType = "role";
            });
        }
        else
        {
            // Public health/policy remain available; every protected route denies access.
            authentication.AddScheme<AuthenticationSchemeOptions, UnconfiguredIdentityHandler>(
                JwtBearerDefaults.AuthenticationScheme, _ => { });
        }

        var studentPolicy = new AuthorizationPolicyBuilder()
            .RequireAuthenticatedUser().RequireRole("Student").RequireAssertion(context =>
                !string.IsNullOrWhiteSpace(context.User.FindFirst("sub")?.Value)
                && !string.IsNullOrWhiteSpace(context.User.FindFirst("university_id")?.Value))
            .Build();
        builder.Services.AddAuthorization(options =>
        {
            options.AddPolicy(StudentPolicy, studentPolicy);
            options.AddPolicy(AdminPolicy, policy => policy.RequireAuthenticatedUser().RequireRole("UniversityAdmin")
                .RequireAssertion(context => !string.IsNullOrWhiteSpace(context.User.FindFirst("sub")?.Value)
                    && !string.IsNullOrWhiteSpace(context.User.FindFirst("university_id")?.Value)));
            options.FallbackPolicy = studentPolicy;
        });
    }

    public static CurrentStudent GetCurrentStudent(this HttpContext context) => new(
        context.User.FindFirst("sub")!.Value, context.User.FindFirst("university_id")!.Value);
}

public sealed class UnconfiguredIdentityHandler(
    IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder)
    : AuthenticationHandler<AuthenticationSchemeOptions>(options, logger, encoder)
{
    protected override Task<AuthenticateResult> HandleAuthenticateAsync() =>
        Task.FromResult(AuthenticateResult.NoResult());
}

using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using Microsoft.IdentityModel.Tokens;
using Thrive.Contracts;

namespace Thrive.Api.Identity;

public sealed class DevelopmentTokenIssuer(TimeProvider timeProvider)
{
    public const string Issuer = "thrive-test-local-development";
    public const string Audience = "thrive-test-local-student";
    public SymmetricSecurityKey SigningKey { get; } = new(RandomNumberGenerator.GetBytes(64));

    public DevelopmentSessionResponse? Issue(string persona)
    {
        var identity = persona switch
        {
            "student-a" => (Subject: "demo-student-a", University: "demo-university", Name: "Demo Student A"),
            "student-b" => (Subject: "demo-student-b", University: "demo-university", Name: "Demo Student B"),
            "student-other-university" => (Subject: "demo-student-a", University: "demo-other-university", Name: "Demo Other University"),
            "admin" => (Subject: "demo-admin", University: "demo-university", Name: "Demo University Admin"),
            "admin-other-university" => (Subject: "demo-admin", University: "demo-other-university", Name: "Demo Other University Admin"),
            _ => default
        };
        if (identity.Subject is null)
            return null;

        var now = timeProvider.GetUtcNow();
        var expires = now.AddHours(1);
        var token = new JwtSecurityToken(
            Issuer, Audience,
            [new Claim("sub", identity.Subject), new Claim("university_id", identity.University),
             new Claim("name", identity.Name), new Claim("development_identity", "true"),
             new Claim("role", persona.StartsWith("admin", StringComparison.Ordinal) ? "UniversityAdmin" : "Student")],
            now.UtcDateTime, expires.UtcDateTime,
            new SigningCredentials(SigningKey, SecurityAlgorithms.HmacSha256));
        return new DevelopmentSessionResponse(new JwtSecurityTokenHandler().WriteToken(token), expires);
    }
}

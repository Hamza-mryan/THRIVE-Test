using Thrive.Api.Identity;
using Thrive.Contracts;

namespace Thrive.Api.Endpoints;

public static class IdentityEndpoints
{
    public static void MapIdentityEndpoints(this WebApplication app)
    {
        app.MapGet("/api/v1/me", (HttpContext context) =>
        {
            var student = context.GetCurrentStudent();
            return new StudentResponse(student.SubjectId, student.UniversityId,
                context.User.FindFirst("name")?.Value ?? "",
                context.User.FindFirst("development_identity")?.Value == "true", context.User.FindFirst("role")?.Value ?? "");
        }).RequireAuthorization(policy => policy.RequireAuthenticatedUser().RequireClaim("sub").RequireClaim("university_id")).WithTags("Identity")
            .ProducesProblem(StatusCodes.Status401Unauthorized)
            .ProducesProblem(StatusCodes.Status403Forbidden);

        if (app.Environment.IsDevelopment() && app.Configuration.GetValue<bool>("DevelopmentIdentity:Enabled"))
        {
            app.MapPost("/api/v1/development/session", (DevelopmentSessionRequest request, DevelopmentTokenIssuer issuer) =>
            {
                var session = issuer.Issue(request.Persona);
                return session is null
                    ? Results.ValidationProblem(new Dictionary<string, string[]> { ["persona"] = ["Unknown synthetic persona."] })
                    : Results.Ok(session);
            }).AllowAnonymous().WithTags("Development")
                .Produces<DevelopmentSessionResponse>().ProducesValidationProblem();
        }
    }
}

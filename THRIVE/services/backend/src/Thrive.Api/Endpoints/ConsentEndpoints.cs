using Microsoft.OpenApi;
using Thrive.Api.Identity;
using Thrive.Application.Consent;
using Thrive.Contracts;
using Thrive.Domain.Consent;

namespace Thrive.Api.Endpoints;

public static class ConsentEndpoints
{
    public static void MapConsentEndpoints(this WebApplication app)
    {
        app.MapGet("/api/v1/consent-policies/current", () =>
        {
            var policy = ConsentPolicy.Current;
            return new ConsentPolicyResponse(policy.Version, policy.ServiceTextAr, policy.ServiceTextEn,
                policy.ResearchTextAr, policy.ResearchTextEn);
        }).AllowAnonymous().WithTags("Consent");

        var group = app.MapGroup("/api/v1/me/consents")
            .RequireAuthorization(IdentityRegistration.StudentPolicy).WithTags("Consent");
        group.MapPost("/withdraw", async (HttpContext context, ConsentService service, CancellationToken ct) =>
            ToResponse(await service.WithdrawAsync(context.GetCurrentStudent(), ct)));
        group.MapGet("", async (HttpContext context, ConsentService service, CancellationToken cancellationToken) =>
        {
            var decision = await service.GetCurrentAsync(context.GetCurrentStudent(), cancellationToken);
            // A literal JSON null is part of the client contract; Json(null) writes no body.
            if (decision is null)
                return (IResult)Results.Content("null", "application/json", statusCode: StatusCodes.Status200OK);
            return Results.Ok(ToResponse(decision));
        }).Produces<ConsentResponse>()
            .ProducesProblem(StatusCodes.Status401Unauthorized)
            .ProducesProblem(StatusCodes.Status403Forbidden)
            .WithDescription("Returns the latest consent decision, or JSON null before the first decision.")
            .AddOpenApiOperationTransformer((operation, _, _) =>
            {
                var response = operation.Responses!["200"].Content!["application/json"];
                // Wrap this operation only; PUT always returns a non-null decision.
                response.Schema = new OpenApiSchema
                {
                    OneOf = [response.Schema!, new OpenApiSchema { Type = JsonSchemaType.Null }]
                };
                return Task.CompletedTask;
            });
        group.MapPut("", async (RecordConsentRequest request, HttpContext context,
            ConsentService service, CancellationToken cancellationToken) =>
        {
            try
            {
                var decision = await service.RecordAsync(context.GetCurrentStudent(), request.PolicyVersion,
                    request.ServiceUse, request.ResearchUse, cancellationToken);
                return Results.Ok(ToResponse(decision));
            }
            catch (ConsentValidationException exception)
            {
                return Results.ValidationProblem(new Dictionary<string, string[]>
                {
                    [exception.Field] = [exception.Message]
                });
            }
        }).Produces<ConsentResponse>().ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status401Unauthorized)
            .ProducesProblem(StatusCodes.Status403Forbidden);
    }

    private static ConsentResponse ToResponse(ConsentDecision decision) => new(
        decision.PolicyVersion, decision.ServiceUse, decision.ResearchUse, decision.RecordedAtUtc);
}

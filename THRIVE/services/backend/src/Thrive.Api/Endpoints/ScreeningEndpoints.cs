using Thrive.Api.Identity;
using Thrive.Application.Screening;
using Thrive.Contracts;

namespace Thrive.Api.Endpoints;

public static class ScreeningEndpoints
{
    public static void MapScreeningEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/v1").RequireAuthorization(IdentityRegistration.StudentPolicy)
            .AddEndpointFilter<FeatureExceptionFilter>().AddEndpointFilter<CurrentConsentFilter>().WithTags("Screening");
        group.MapGet("/instruments", (HttpContext context) => context.IsDemo() ? new[] { DemoInstrument.Definition } : []);
        group.MapPost("/screening/sessions", async (StartSessionRequest request, HttpContext context, ScreeningWorkflow workflow, CancellationToken ct) =>
            FeatureMapping.Session(await workflow.StartAsync(context.GetCurrentStudent(), request.InstrumentCode, context.IsDemo(), ct)));
        group.MapGet("/screening/sessions/{id:guid}", async (Guid id, HttpContext context, ScreeningWorkflow workflow, CancellationToken ct) =>
            FeatureMapping.Session(await workflow.GetAsync(context.GetCurrentStudent(), id, ct)));
        group.MapPut("/screening/sessions/{id:guid}/answers/{itemCode}", async (Guid id, string itemCode, AnswerRequest request, HttpContext context, ScreeningWorkflow workflow, CancellationToken ct) =>
            FeatureMapping.Session(await workflow.AnswerAsync(context.GetCurrentStudent(), id, itemCode, request.Value, ct)));
        group.MapPost("/screening/sessions/{id:guid}/submit", async (Guid id, HttpContext context, ScreeningWorkflow workflow, CancellationToken ct) =>
            FeatureMapping.Result(await workflow.SubmitAsync(context.GetCurrentStudent(), id, ct)));
        group.MapGet("/me/screenings", async (HttpContext context, ScreeningWorkflow workflow, CancellationToken ct) =>
            (await workflow.ListAsync(context.GetCurrentStudent(), ct)).Select(FeatureMapping.Session));
    }
}

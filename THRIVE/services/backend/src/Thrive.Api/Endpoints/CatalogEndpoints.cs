using Thrive.Api.Identity;
using Thrive.Application.Catalog;
using Thrive.Application.Features;

namespace Thrive.Api.Endpoints;

public static class CatalogEndpoints
{
    public static void MapCatalogEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/v1").RequireAuthorization(IdentityRegistration.StudentPolicy)
            .AddEndpointFilter<FeatureExceptionFilter>().AddEndpointFilter<CurrentConsentFilter>().WithTags("Catalog");
        group.MapGet("/services", async (string? level, HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            (await catalog.ServicesAsync(context.GetCurrentStudent().UniversityId, false, context.IsDemo(), level, ct)).Select(FeatureMapping.Service));
        group.MapGet("/guide/resources", async (HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            (await catalog.ResourcesAsync(context.GetCurrentStudent().UniversityId, false, context.IsDemo(), ct)).Select(FeatureMapping.Resource));
        group.MapGet("/guide/resources/{id:guid}", async (Guid id, HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
        {
            var resource = await catalog.ResourceAsync(context.GetCurrentStudent().UniversityId, id, ct);
            if (!resource.Published || resource.IsDemo && !context.IsDemo()) throw new FeatureException(404, "Resource not found.");
            return FeatureMapping.Resource(resource);
        });
    }
}

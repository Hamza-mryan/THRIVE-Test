using Thrive.Api.Identity;
using Thrive.Application.Catalog;
using Thrive.Application.Referrals;
using Thrive.Contracts;

namespace Thrive.Api.Endpoints;

public static class AdminEndpoints
{
    public static void MapAdminEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/v1/admin").RequireAuthorization(IdentityRegistration.AdminPolicy)
            .AddEndpointFilter<FeatureExceptionFilter>().WithTags("Administration");
        group.MapGet("/services", async (HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            (await catalog.ServicesAsync(context.GetCurrentStudent().UniversityId, true, context.IsDemo(), null, ct)).Select(FeatureMapping.Service));
        group.MapPost("/services", async (ServiceWrite request, HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            FeatureMapping.Service(await catalog.SaveServiceAsync(context.GetCurrentStudent().UniversityId, null, Input(request), context.IsDemo(), ct)));
        group.MapPut("/services/{id:guid}", async (Guid id, ServiceWrite request, HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            FeatureMapping.Service(await catalog.SaveServiceAsync(context.GetCurrentStudent().UniversityId, id, Input(request), context.IsDemo(), ct)));
        group.MapGet("/resources", async (HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            (await catalog.ResourcesAsync(context.GetCurrentStudent().UniversityId, true, context.IsDemo(), ct)).Select(FeatureMapping.Resource));
        group.MapPost("/resources", async (ResourceWrite request, HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            FeatureMapping.Resource(await catalog.SaveResourceAsync(context.GetCurrentStudent().UniversityId, null, Input(request), context.IsDemo(), ct)));
        group.MapPut("/resources/{id:guid}", async (Guid id, ResourceWrite request, HttpContext context, CatalogWorkflow catalog, CancellationToken ct) =>
            FeatureMapping.Resource(await catalog.SaveResourceAsync(context.GetCurrentStudent().UniversityId, id, Input(request), context.IsDemo(), ct)));
        group.MapGet("/referrals", async (HttpContext context, ReferralWorkflow referrals, CancellationToken ct) =>
            (await referrals.ListAsync(context.GetCurrentStudent(), true, ct)).Select(FeatureMapping.Referral));
        group.MapPut("/referrals/{id:guid}/status", async (Guid id, ReferralStatusRequest request, HttpContext context, ReferralWorkflow referrals, CancellationToken ct) =>
            FeatureMapping.Referral(await referrals.TransitionAsync(context.GetCurrentStudent(), id, request.Status, true, ct)));
        group.MapGet("/reports/aggregate", async (HttpContext context, CatalogWorkflow catalog, ReferralWorkflow referrals, CancellationToken ct) =>
        {
            var university = context.GetCurrentStudent().UniversityId;
            var counts = await referrals.CountsAsync(university, ct);
            return new AggregateReportResponse(Suppress(counts.Screenings), Suppress(counts.Referrals), Suppress(counts.Completed), 5,
                (await catalog.ResourcesAsync(university, true, context.IsDemo(), ct)).Count(x => x.Published),
                (await catalog.ServicesAsync(university, true, context.IsDemo(), null, ct)).Count(x => x.Active));
        });
    }
    private static int? Suppress(int count) => count < 5 ? null : count;
    private static ServiceInput Input(ServiceWrite x) => new(x.Level, x.NameAr, x.NameEn, x.DescriptionAr, x.DescriptionEn, x.HoursAr, x.HoursEn, x.LocationAr, x.LocationEn, x.BookingMethod, x.ContactUrl, x.Verified, x.Active, x.Phone, x.Email, x.Specialty, x.Source);
    private static ResourceInput Input(ResourceWrite x) => new(x.Slug, x.TitleAr, x.TitleEn, x.SummaryAr, x.SummaryEn, x.BodyAr, x.BodyEn, x.Category, x.Source, x.Version, x.Published);
}

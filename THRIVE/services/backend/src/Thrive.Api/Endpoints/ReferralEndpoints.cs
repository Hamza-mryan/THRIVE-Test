using Thrive.Api.Identity;
using Thrive.Application.Referrals;
using Thrive.Contracts;

namespace Thrive.Api.Endpoints;

public static class ReferralEndpoints
{
    public static void MapReferralEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/v1").RequireAuthorization(IdentityRegistration.StudentPolicy)
            .AddEndpointFilter<FeatureExceptionFilter>().AddEndpointFilter<CurrentConsentFilter>().WithTags("Referrals");
        group.MapPost("/referrals", async (ReferralRequest request, HttpContext context, ReferralWorkflow workflow, CancellationToken ct) =>
            FeatureMapping.Referral(await workflow.RequestAsync(context.GetCurrentStudent(), request.ServiceId, request.ShareConsent, context.IsDemo(), ct)));
        group.MapGet("/me/referrals", async (HttpContext context, ReferralWorkflow workflow, CancellationToken ct) =>
            (await workflow.ListAsync(context.GetCurrentStudent(), false, ct)).Select(FeatureMapping.Referral));
        group.MapPost("/me/referrals/{id:guid}/cancel", async (Guid id, HttpContext context, ReferralWorkflow workflow, CancellationToken ct) =>
            FeatureMapping.Referral(await workflow.TransitionAsync(context.GetCurrentStudent(), id, "Cancelled", false, ct)));
    }
}

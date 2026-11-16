using Microsoft.EntityFrameworkCore;
using Thrive.Api.Identity;
using Thrive.Application.Consent;
using Thrive.Application.Features;

namespace Thrive.Api.Endpoints;

public sealed class FeatureExceptionFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        try { return await next(context); }
        catch (FeatureException exception) { return Results.Problem(statusCode: exception.StatusCode, detail: exception.Message); }
        catch (DbUpdateConcurrencyException) { return Results.Problem(statusCode: 409, detail: "The record changed. Refresh and retry."); }
        catch (DbUpdateException) { return Results.Problem(statusCode: 409, detail: "This operation conflicts with an existing record. Refresh and retry."); }
    }
}

public sealed class CurrentConsentFilter(ConsentService consent) : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var choice = await consent.GetCurrentAsync(context.HttpContext.GetCurrentStudent(), context.HttpContext.RequestAborted);
        return choice?.ServiceUse == true && choice.PolicyVersion == ConsentPolicy.Current.Version
            ? await next(context)
            : Results.Problem(statusCode: 403, detail: "Accept the current service policy before using this pathway. Research participation is optional.");
    }
}

public static class DevelopmentMode
{
    public static bool IsDemo(this HttpContext context) =>
        context.RequestServices.GetRequiredService<IHostEnvironment>().IsDevelopment()
        && context.RequestServices.GetRequiredService<IConfiguration>().GetValue<bool>("DevelopmentIdentity:Enabled")
        && context.User.FindFirst("development_identity")?.Value == "true";
}

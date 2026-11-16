using Thrive.Application.Features;
using Thrive.Domain.Catalog;

namespace Thrive.Application.Catalog;

public sealed record ServiceInput(string Level, string NameAr, string NameEn, string DescriptionAr, string DescriptionEn, string HoursAr, string HoursEn, string LocationAr, string LocationEn, string BookingMethod, string? ContactUrl, bool Verified, bool Active, string? Phone = null, string? Email = null, string? Specialty = null, string? Source = null);
public sealed record ResourceInput(string Slug, string TitleAr, string TitleEn, string SummaryAr, string SummaryEn, string BodyAr, string BodyEn, string Category, string Source, string Version, bool Published);

public sealed class CatalogWorkflow(ICatalogStore store)
{
    public async Task<IReadOnlyList<UniversityService>> ServicesAsync(string university, bool admin, bool demo, string? level, CancellationToken ct)
    {
        FeatureValidation.Require(level is null or "Counseling" or "Specialist", "Unknown service level.");
        if (demo) await store.SeedDemoAsync(university, ct);
        var services = await store.ServicesAsync(university, ct);
        return services.Where(x => (demo || !x.IsDemo)
            && (admin || x.Active && (x.Verified && !x.IsDemo || demo && x.IsDemo))
            && (level is null || x.Level == level)).ToArray();
    }
    public async Task<IReadOnlyList<GuideResource>> ResourcesAsync(string university, bool admin, bool demo, CancellationToken ct)
    {
        if (demo) await store.SeedDemoAsync(university, ct);
        return (await store.ResourcesAsync(university, ct)).Where(x => (admin || x.Published) && (demo || !x.IsDemo)).ToArray();
    }
    public async Task<UniversityService> ServiceAsync(string university, Guid id, CancellationToken ct) => await store.ServiceAsync(university, id, ct) ?? throw new FeatureException(404, "Service not found.");
    public async Task<GuideResource> ResourceAsync(string university, Guid id, CancellationToken ct) => await store.ResourceAsync(university, id, ct) ?? throw new FeatureException(404, "Resource not found.");

    public async Task<UniversityService> SaveServiceAsync(string university, Guid? id, ServiceInput input, bool demo, CancellationToken ct)
    {
        FeatureValidation.Require(input.Level is "Counseling" or "Specialist", "Unknown service level.");
        FeatureValidation.Require(input.ContactUrl is null || Uri.TryCreate(input.ContactUrl, UriKind.Absolute, out var uri) && uri.Scheme == "https", "Contact URL must use HTTPS.");
        var phone = OptionalText(input.Phone, "phone", 32);
        var email = OptionalText(input.Email, "email", 254);
        var specialty = OptionalText(input.Specialty, "specialty", 40);
        var source = OptionalText(input.Source, "source", 500);
        FeatureValidation.Require(phone is null || System.Text.RegularExpressions.Regex.IsMatch(phone, @"^\+?[0-9][0-9 ()-]{5,24}$"), "Phone must contain a valid dialing number.");
        FeatureValidation.Require(email is null || System.Net.Mail.MailAddress.TryCreate(email, out var address) && address.Address == email && !email.Contains('\r') && !email.Contains('\n'), "Email must be a plain email address.");
        FeatureValidation.Require(specialty is null or "Psychology" or "Psychiatry", "Unknown service specialty.");
        // Verification needs institution reviewer evidence, not a checkbox on an unapproved directory.
        FeatureValidation.Require(!input.Verified, "Institution verification evidence is not configured. Save as unverified.");
        var service = id is null ? new UniversityService { UniversityId = university, IsDemo = demo } : await ServiceAsync(university, id.Value, ct);
        service.Level = input.Level;
        service.NameAr = FeatureValidation.Text(input.NameAr, "nameAr", 200);
        service.NameEn = FeatureValidation.Text(input.NameEn, "nameEn", 200);
        service.DescriptionAr = FeatureValidation.Text(input.DescriptionAr, "descriptionAr");
        service.DescriptionEn = FeatureValidation.Text(input.DescriptionEn, "descriptionEn");
        service.HoursAr = FeatureValidation.Text(input.HoursAr, "hoursAr", 300);
        service.HoursEn = FeatureValidation.Text(input.HoursEn, "hoursEn", 300);
        service.LocationAr = FeatureValidation.Text(input.LocationAr, "locationAr", 300);
        service.LocationEn = FeatureValidation.Text(input.LocationEn, "locationEn", 300);
        service.BookingMethod = FeatureValidation.Text(input.BookingMethod, "bookingMethod", 300);
        service.ContactUrl = input.ContactUrl;
        service.Phone = phone;
        service.Email = email;
        service.Specialty = specialty;
        service.Source = source;
        service.Active = input.Active;
        service.Verified = false;
        if (id is null) await store.AddServiceAsync(service, ct); else await store.SaveAsync(ct);
        return service;
    }

    private static string? OptionalText(string? value, string field, int maxLength) =>
        string.IsNullOrWhiteSpace(value) ? null : FeatureValidation.Text(value, field, maxLength);

    public async Task<GuideResource> SaveResourceAsync(string university, Guid? id, ResourceInput input, bool demo, CancellationToken ct)
    {
        var resource = id is null ? new GuideResource { UniversityId = university, IsDemo = demo } : await ResourceAsync(university, id.Value, ct);
        resource.Slug = FeatureValidation.Text(input.Slug, "slug", 100);
        FeatureValidation.Require(System.Text.RegularExpressions.Regex.IsMatch(resource.Slug, "^[a-z0-9]+(?:-[a-z0-9]+)*$"), "Slug must contain lowercase letters, digits and hyphens.");
        var resources = await store.ResourcesAsync(university, ct);
        if (resources.Any(x => x.Id != resource.Id && x.Slug == resource.Slug)) throw new FeatureException(409, "Resource slug already exists.");
        resource.TitleAr = FeatureValidation.Text(input.TitleAr, "titleAr", 200);
        resource.TitleEn = FeatureValidation.Text(input.TitleEn, "titleEn", 200);
        resource.SummaryAr = FeatureValidation.Text(input.SummaryAr, "summaryAr");
        resource.SummaryEn = FeatureValidation.Text(input.SummaryEn, "summaryEn");
        resource.BodyAr = FeatureValidation.Text(input.BodyAr, "bodyAr", 20000);
        resource.BodyEn = FeatureValidation.Text(input.BodyEn, "bodyEn", 20000);
        resource.Category = FeatureValidation.Text(input.Category, "category", 100);
        resource.Source = FeatureValidation.Text(input.Source, "source", 500);
        resource.Version = FeatureValidation.Text(input.Version, "version", 80);
        resource.Published = input.Published;
        if (id is null) await store.AddResourceAsync(resource, ct); else await store.SaveAsync(ct);
        return resource;
    }
}

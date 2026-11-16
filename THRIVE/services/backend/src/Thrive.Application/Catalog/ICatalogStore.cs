using Thrive.Domain.Catalog;

namespace Thrive.Application.Catalog;

public interface ICatalogStore
{
    Task<IReadOnlyList<UniversityService>> ServicesAsync(string university, CancellationToken ct);
    Task<IReadOnlyList<GuideResource>> ResourcesAsync(string university, CancellationToken ct);
    Task<UniversityService?> ServiceAsync(string university, Guid id, CancellationToken ct);
    Task<GuideResource?> ResourceAsync(string university, Guid id, CancellationToken ct);
    Task AddServiceAsync(UniversityService service, CancellationToken ct);
    Task AddResourceAsync(GuideResource resource, CancellationToken ct);
    Task SaveAsync(CancellationToken ct);
    Task SeedDemoAsync(string university, CancellationToken ct);
}

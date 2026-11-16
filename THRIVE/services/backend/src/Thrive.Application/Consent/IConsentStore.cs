using Thrive.Application.Identity;
using Thrive.Domain.Consent;

namespace Thrive.Application.Consent;

public interface IConsentStore
{
    Task<ConsentDecision?> GetLatestAsync(CurrentStudent student, CancellationToken cancellationToken);
    Task SaveAsync(ConsentDecision decision, CancellationToken cancellationToken);
}

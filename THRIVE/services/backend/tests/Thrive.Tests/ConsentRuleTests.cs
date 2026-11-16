using Thrive.Application.Consent;
using Thrive.Application.Identity;
using Thrive.Domain.Consent;

namespace Thrive.Tests;

public sealed class ConsentRuleTests
{
    private static readonly CurrentStudent Student = new("student", "university");

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task ResearchChoiceDoesNotBlockServiceConsent(bool researchUse)
    {
        var store = new TestConsentStore();
        var service = new ConsentService(store, TimeProvider.System);

        var decision = await service.RecordAsync(Student, ConsentPolicy.Current.Version,
            true, researchUse, CancellationToken.None);

        Assert.True(decision.ServiceUse);
        Assert.Equal(researchUse, decision.ResearchUse);
        Assert.Equal(1, store.SaveCount);
    }

    [Fact]
    public async Task StalePolicyIsRejectedBeforeWriting()
    {
        var store = new TestConsentStore();
        var service = new ConsentService(store, TimeProvider.System);

        var exception = await Assert.ThrowsAsync<ConsentValidationException>(() =>
            service.RecordAsync(Student, "old-policy", true, false, CancellationToken.None));

        Assert.Equal("policyVersion", exception.Field);
        Assert.Equal(0, store.SaveCount);
    }

    [Fact]
    public async Task OnboardingRequiresServiceConsentRegardlessOfResearchChoice()
    {
        var store = new TestConsentStore();
        var service = new ConsentService(store, TimeProvider.System);

        var exception = await Assert.ThrowsAsync<ConsentValidationException>(() =>
            service.RecordAsync(Student, ConsentPolicy.Current.Version, false, true, CancellationToken.None));

        Assert.Equal("serviceUse", exception.Field);
        Assert.Equal(0, store.SaveCount);
    }

    [Fact]
    public async Task RetryingSameDecisionDoesNotAppendAnotherEvent()
    {
        var store = new TestConsentStore();
        var service = new ConsentService(store, TimeProvider.System);

        var first = await service.RecordAsync(Student, ConsentPolicy.Current.Version, true, false, CancellationToken.None);
        var retry = await service.RecordAsync(Student, ConsentPolicy.Current.Version, true, false, CancellationToken.None);

        Assert.Equal(first.Id, retry.Id);
        Assert.Equal(1, store.SaveCount);
    }

    [Fact]
    public void DomainRejectsBlankIdentityAndNormalizesRecordedTime()
    {
        Assert.Throws<ArgumentException>(() => ConsentDecision.Record("", "university", "policy", true, false, DateTimeOffset.UtcNow));
        var decision = ConsentDecision.Record("student", "university", "policy", true, false,
            new DateTimeOffset(2026, 11, 3, 12, 0, 0, TimeSpan.FromHours(3)));
        Assert.Equal(TimeSpan.Zero, decision.RecordedAtUtc.Offset);
    }

    private sealed class TestConsentStore : IConsentStore
    {
        private ConsentDecision? _latest;
        public int SaveCount { get; private set; }

        public Task<ConsentDecision?> GetLatestAsync(CurrentStudent student, CancellationToken cancellationToken) =>
            Task.FromResult(_latest);

        public Task SaveAsync(ConsentDecision decision, CancellationToken cancellationToken)
        {
            _latest = decision;
            SaveCount++;
            return Task.CompletedTask;
        }
    }
}

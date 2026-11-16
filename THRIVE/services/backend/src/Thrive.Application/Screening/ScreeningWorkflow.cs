using Thrive.Application.Features;
using Thrive.Application.Identity;
using Thrive.Domain.Screening;
using Thrive.Domain;

namespace Thrive.Application.Screening;

public interface IScreeningStore
{
    Task<ScreeningSession?> FindAsync(CurrentStudent student, Guid id, CancellationToken ct);
    Task<IReadOnlyList<ScreeningSession>> ListAsync(CurrentStudent student, CancellationToken ct);
    Task AddAsync(ScreeningSession session, CancellationToken ct);
    Task SaveAsync(ScreeningSession session, string action, DateTimeOffset occurredAtUtc, CancellationToken ct);
}

public sealed class ScreeningWorkflow(IScreeningStore store, TimeProvider clock)
{
    public Task<IReadOnlyList<ScreeningSession>> ListAsync(CurrentStudent student, CancellationToken ct) => store.ListAsync(student, ct);
    public async Task<ScreeningSession> GetAsync(CurrentStudent student, Guid id, CancellationToken ct) =>
        await store.FindAsync(student, id, ct) ?? throw new FeatureException(404, "Session not found.");

    public async Task<ScreeningSession> StartAsync(CurrentStudent student, string code, bool demo, CancellationToken ct)
    {
        FeatureValidation.Require(demo && code == DemoInstrument.Code, "No institution-approved clinical instrument is configured. Only the development usability demo is available.");
        var session = new ScreeningSession { SubjectId = student.SubjectId, UniversityId = student.UniversityId, InstrumentCode = code, InstrumentVersion = DemoInstrument.Version, StartedAtUtc = UtcTimestamp.Normalize(clock.GetUtcNow()) };
        await store.AddAsync(session, ct);
        return session;
    }

    public async Task<ScreeningSession> AnswerAsync(CurrentStudent student, Guid id, string itemCode, int value, CancellationToken ct)
    {
        var session = await GetAsync(student, id, ct);
        if (session.CompletedAtUtc is not null) throw new FeatureException(409, "Submitted sessions cannot be edited.");
        var item = DemoInstrument.Definition.Items.SingleOrDefault(x => x.Code == itemCode);
        FeatureValidation.Require(item is not null && item.Options.Any(x => x.Value == value), "Unknown item or answer option.");
        var answer = session.Answers.SingleOrDefault(x => x.ItemCode == itemCode);
        if (answer is null) session.Answers.Add(new ScreeningAnswer { SessionId = id, ItemCode = itemCode, Value = value });
        else answer.Value = value;
        session.Revision++;
        await store.SaveAsync(session, "screening.answer.saved", UtcTimestamp.Normalize(clock.GetUtcNow()), ct);
        return session;
    }

    public async Task<ScreeningSession> SubmitAsync(CurrentStudent student, Guid id, CancellationToken ct)
    {
        var session = await GetAsync(student, id, ct);
        if (session.CompletedAtUtc is not null) return session;
        FeatureValidation.Require(session.InstrumentVersion == DemoInstrument.Version && DemoInstrument.Definition.Items.All(item => session.Answers.Any(answer => answer.ItemCode == item.Code && item.Options.Any(option => option.Value == answer.Value))), "Complete every item before submitting.");
        session.RawScore = session.Answers.Sum(x => x.Value);
        session.CompletedAtUtc = UtcTimestamp.Normalize(clock.GetUtcNow());
        session.Revision++;
        await store.SaveAsync(session, "screening.submitted", session.CompletedAtUtc.Value, ct);
        return session;
    }
}

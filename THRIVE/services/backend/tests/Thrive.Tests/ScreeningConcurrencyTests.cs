using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Thrive.Application.Identity;
using Thrive.Application.Screening;
using Thrive.Infrastructure.Persistence;

namespace Thrive.Tests;

public sealed class ScreeningConcurrencyTests
{
    [Fact]
    public async Task LateAnswerCannotChangeAConcurrentlySubmittedSession()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var options = new DbContextOptionsBuilder<ThriveDbContext>().UseSqlite(connection).Options;
        await using var initial = new ThriveDbContext(options);
        await initial.Database.EnsureCreatedAsync();
        var student = new CurrentStudent("synthetic", "test-university");
        var initialWorkflow = new ScreeningWorkflow(new EfScreeningStore(initial), TimeProvider.System);
        var session = await initialWorkflow.StartAsync(student, DemoInstrument.Code, true, default);
        foreach (var item in DemoInstrument.Definition.Items)
            await initialWorkflow.AnswerAsync(student, session.Id, item.Code, 1, default);

        await using var lateContext = new ThriveDbContext(options);
        var lateWorkflow = new ScreeningWorkflow(new EfScreeningStore(lateContext), TimeProvider.System);
        await lateWorkflow.GetAsync(student, session.Id, default); // Loaded while still editable.
        await initialWorkflow.SubmitAsync(student, session.Id, default);

        await Assert.ThrowsAsync<DbUpdateConcurrencyException>(() =>
            lateWorkflow.AnswerAsync(student, session.Id, "navigation", 2, default));
        await using var verify = new ThriveDbContext(options);
        var saved = await verify.ScreeningSessions.Include(x => x.Answers).SingleAsync();
        Assert.NotNull(saved.CompletedAtUtc);
        Assert.Equal(3, saved.RawScore);
        Assert.All(saved.Answers, answer => Assert.Equal(1, answer.Value));
    }
}

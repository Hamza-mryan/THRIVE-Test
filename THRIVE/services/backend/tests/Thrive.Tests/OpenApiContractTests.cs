using System.Text.Json;

namespace Thrive.Tests;

public sealed class OpenApiContractTests
{
    [Fact]
    public async Task ClientContractDescribesConsentNullabilityErrorsAndAuthentication()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        using var document = JsonDocument.Parse(await client.GetStringAsync("/openapi/v1.json"));
        var paths = document.RootElement.GetProperty("paths");
        var consent = paths.GetProperty("/api/v1/me/consents");
        var get = consent.GetProperty("get");
        var put = consent.GetProperty("put");
        var session = paths.GetProperty("/api/v1/development/session").GetProperty("post");

        var nullableSchema = SuccessSchema(get);
        Assert.Contains(nullableSchema.GetProperty("oneOf").EnumerateArray(), schema =>
            schema.TryGetProperty("type", out var type) && type.GetString() == "null");
        Assert.True(SuccessSchema(put).TryGetProperty("$ref", out _));
        Assert.True(SuccessSchema(session).TryGetProperty("$ref", out _));
        Assert.True(put.GetProperty("responses").TryGetProperty("400", out _));
        Assert.True(session.GetProperty("responses").TryGetProperty("400", out _));
        foreach (var operation in new[] { get, put })
        {
            Assert.True(operation.GetProperty("responses").TryGetProperty("401", out _));
            Assert.True(operation.GetProperty("responses").TryGetProperty("403", out _));
            Assert.True(operation.GetProperty("security")[0].TryGetProperty("Bearer", out _));
        }
        Assert.False(session.TryGetProperty("security", out _));
        Assert.True(document.RootElement.GetProperty("components").GetProperty("securitySchemes")
            .TryGetProperty("Bearer", out _));
    }

    private static JsonElement SuccessSchema(JsonElement operation) => operation.GetProperty("responses")
        .GetProperty("200").GetProperty("content").GetProperty("application/json").GetProperty("schema");
}

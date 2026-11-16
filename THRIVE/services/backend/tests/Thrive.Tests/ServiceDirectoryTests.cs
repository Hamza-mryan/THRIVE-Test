using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Thrive.Application.Consent;
using Thrive.Contracts;

namespace Thrive.Tests;

public sealed class ServiceDirectoryTests
{
    [Fact]
    public async Task DeclaredSpecialtyContactsAndSourceRoundTripWithoutGrantingVerification()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Login(client, "admin");
        var body = Service() with { Phone = "+962 6 000 0000", Email = "directory@example.invalid", Specialty = "Psychology", Source = "  Synthetic test fixture, not a real provider  " };
        var response = await client.PostAsJsonAsync("/api/v1/admin/services", body);
        response.EnsureSuccessStatusCode();
        var saved = (await response.Content.ReadFromJsonAsync<ServiceResponse>())!;
        Assert.Equal(body.Phone, saved.Phone);
        Assert.Equal(body.Email, saved.Email);
        Assert.Equal("Psychology", saved.Specialty);
        Assert.Equal(body.Source.Trim(), saved.Source);
        Assert.True(saved.IsDemo);
        Assert.False(saved.Verified);
        await Login(client, "student-a");
        (await client.PutAsJsonAsync("/api/v1/me/consents", new RecordConsentRequest(ConsentPolicy.Current.Version, true, false))).EnsureSuccessStatusCode();
        var directory = (await client.GetFromJsonAsync<ServiceResponse[]>("/api/v1/services?level=Specialist"))!;
        Assert.Equal(saved, directory.Single(x => x.Id == saved.Id));
        await Login(client, "admin-other-university");
        Assert.Equal(HttpStatusCode.NotFound, (await client.PutAsJsonAsync($"/api/v1/admin/services/{saved.Id}", body)).StatusCode);
    }

    [Theory]
    [InlineData("phone")]
    [InlineData("email")]
    [InlineData("specialty")]
    [InlineData("email-header")]
    public async Task RejectsInvalidContactAndSpecialtyValues(string field)
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Login(client, "admin");
        var body = field switch
        {
            "phone" => Service() with { Phone = "+962\nnot-a-number" },
            "email" => Service() with { Email = "not-an-email" },
            "email-header" => Service() with { Email = "a@example.invalid\r\nBcc: other@example.invalid" },
            _ => Service() with { Specialty = "UnapprovedCategory" }
        };
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync("/api/v1/admin/services", body)).StatusCode);
    }

    [Fact]
    public async Task ExistingPayloadsRemainValidAndBlankOptionalFieldsAreAbsent()
    {
        using var factory = new ApiFactory();
        using var client = factory.CreateInitializedClient();
        await Login(client, "admin");
        var response = await client.PostAsJsonAsync("/api/v1/admin/services", Service() with { Phone = " ", Email = "", Specialty = " ", Source = " " });
        response.EnsureSuccessStatusCode();
        var saved = (await response.Content.ReadFromJsonAsync<ServiceResponse>())!;
        Assert.Null(saved.Phone);
        Assert.Null(saved.Email);
        Assert.Null(saved.Specialty);
        Assert.Null(saved.Source);
    }

    private static ServiceWrite Service() => new("Specialist", "دليل تجريبي", "Test directory", "بيانات اختبار اصطناعية", "Synthetic test fixture", "غير مطبق", "Not applicable", "افتراضي", "Simulated", "InternalRequest", null, false, true);

    private static async Task Login(HttpClient client, string persona)
    {
        var response = await client.PostAsJsonAsync("/api/v1/development/session", new DevelopmentSessionRequest(persona));
        response.EnsureSuccessStatusCode();
        var session = (await response.Content.ReadFromJsonAsync<DevelopmentSessionResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", session.AccessToken);
    }
}

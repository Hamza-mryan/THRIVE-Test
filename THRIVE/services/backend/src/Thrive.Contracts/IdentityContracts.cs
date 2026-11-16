namespace Thrive.Contracts;

public sealed record StudentResponse(
    string SubjectId, string UniversityId, string DisplayName, bool IsDevelopmentIdentity, string Role = "Student");

public sealed record DevelopmentSessionRequest(string Persona);

public sealed record DevelopmentSessionResponse(string AccessToken, DateTimeOffset ExpiresAtUtc);

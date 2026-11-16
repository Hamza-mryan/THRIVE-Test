namespace Thrive.Contracts;

public sealed record ConsentPolicyResponse(
    string Version, string ServiceTextAr, string ServiceTextEn,
    string ResearchTextAr, string ResearchTextEn);

public sealed record RecordConsentRequest(string PolicyVersion, bool ServiceUse, bool ResearchUse);

public sealed record ConsentResponse(
    string PolicyVersion, bool ServiceUse, bool ResearchUse, DateTimeOffset RecordedAtUtc);

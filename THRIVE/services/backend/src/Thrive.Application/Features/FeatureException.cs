namespace Thrive.Application.Features;

public sealed class FeatureException(int statusCode, string message) : Exception(message)
{
    public int StatusCode { get; } = statusCode;
}

public static class FeatureValidation
{
    public static void Require(bool condition, string message)
    {
        if (!condition) throw new FeatureException(400, message);
    }

    public static string Text(string? value, string name, int maximum = 2000)
    {
        Require(!string.IsNullOrWhiteSpace(value) && value.Length <= maximum, $"{name} is required and must not exceed {maximum} characters.");
        return value!.Trim();
    }
}

namespace ShenaPari.Api.Auth;

/// Bound from the "Jwt" section of appsettings.
public class JwtOptions
{
    public required string Issuer { get; init; }
    public required string Audience { get; init; }
    /// HMAC-SHA256 signing key, at least 32 characters.
    public required string Key { get; init; }
    public int AccessTokenMinutes { get; init; } = 15;
    public int RefreshTokenDays { get; init; } = 30;
}

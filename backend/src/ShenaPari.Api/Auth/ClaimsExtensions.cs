using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Auth;

/// Reads the logged-in user from the JWT. Only call inside [Authorize].
public static class ClaimsExtensions
{
    public static Guid UserId(this ClaimsPrincipal user) =>
        Guid.Parse(user.FindFirstValue(JwtRegisteredClaimNames.Sub)!);

    /// Id of the login session (RefreshToken row) the access token was issued for.
    public static Guid SessionId(this ClaimsPrincipal user) =>
        Guid.Parse(user.FindFirstValue(JwtRegisteredClaimNames.Sid)!);

    public static UserRole Role(this ClaimsPrincipal user) =>
        Enum.Parse<UserRole>(user.FindFirstValue("role")!);
}

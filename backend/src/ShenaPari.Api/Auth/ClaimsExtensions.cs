using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace ShenaPari.Api.Auth;

public static class ClaimsExtensions
{
    /// Id of the logged-in user from the JWT "sub" claim. Only call inside [Authorize].
    public static Guid UserId(this ClaimsPrincipal user) =>
        Guid.Parse(user.FindFirstValue(JwtRegisteredClaimNames.Sub)!);
}

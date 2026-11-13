using Microsoft.AspNetCore.Authorization;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Auth;

/// Who may call what. Roles are nested, so a policy lists its role and every role above it:
///   [Authorize(Policy = Policies.Cook)]  → Cook, Admin, SuperAdmin
///   [Authorize(Policy = Policies.Admin)] → Admin, SuperAdmin
/// Names of rate-limiting policies (see Program.cs).
public static class RateLimits
{
    public const string Auth = "auth";
}

public static class Policies
{
    public const string Customer = nameof(Customer);
    public const string Cook = nameof(Cook);
    public const string Admin = nameof(Admin);
    public const string SuperAdmin = nameof(SuperAdmin);

    public static void Register(AuthorizationOptions o)
    {
        o.AddPolicy(Customer, p => p.RequireRole(Role(UserRole.Customer)));
        o.AddPolicy(Cook, p => p.RequireRole(Role(UserRole.Cook), Role(UserRole.Admin), Role(UserRole.SuperAdmin)));
        o.AddPolicy(Admin, p => p.RequireRole(Role(UserRole.Admin), Role(UserRole.SuperAdmin)));
        o.AddPolicy(SuperAdmin, p => p.RequireRole(Role(UserRole.SuperAdmin)));
    }

    private static string Role(UserRole r) => r.ToString();
}

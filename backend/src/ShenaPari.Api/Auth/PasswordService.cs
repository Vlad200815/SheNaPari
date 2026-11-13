using Microsoft.AspNetCore.Identity;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Auth;

/// Hashes and checks employee passwords with ASP.NET Core's built-in hasher
/// (PBKDF2 with a random salt per password). Plain passwords are never stored.
public class PasswordService
{
    public const int MinLength = 8;

    private readonly PasswordHasher<Employee> _hasher = new();

    public string Hash(Employee employee, string password) => _hasher.HashPassword(employee, password);

    public bool Verify(Employee employee, string hash, string password) =>
        _hasher.VerifyHashedPassword(employee, hash, password) != PasswordVerificationResult.Failed;
}

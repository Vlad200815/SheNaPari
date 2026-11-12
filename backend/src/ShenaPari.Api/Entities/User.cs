namespace ShenaPari.Api.Entities;

/// Base for everyone who can log in. Stored in ONE table "Users" together with its
/// subclasses (table-per-hierarchy): a "Discriminator" column says which class a row is.
public abstract class User
{
    public Guid Id { get; set; }
    public UserRole Role { get; set; }
    public string? Name { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    /// Set when an admin switches the account off. A deactivated user can't log in.
    public DateTimeOffset? DeactivatedAt { get; set; }

    public bool IsActive => DeactivatedAt is null;
}

/// A student. Logs in with a phone number and an SMS code; has no password.
public class Customer : User
{
    public required string Phone { get; set; }

    public List<Order> Orders { get; set; } = [];
}

/// Canteen staff (Cook, Admin, SuperAdmin). Logs in with e-mail and password;
/// never registers on their own: the account is created by an admin.
public class Employee : User
{
    public required string Email { get; set; }

    public UserCredentials? Credentials { get; set; }
}

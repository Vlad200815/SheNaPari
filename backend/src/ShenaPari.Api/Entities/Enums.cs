namespace ShenaPari.Api.Entities;

public enum UserRole
{
    Student,
    Staff,
}

/// Pending → Accepted → Cooking → Ready → PickedUp;
/// Cancelled is allowed only from Pending or Accepted.
public enum OrderStatus
{
    Pending,
    Accepted,
    Cooking,
    Ready,
    PickedUp,
    Cancelled,
}

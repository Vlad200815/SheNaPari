namespace ShenaPari.Api.Entities;

/// Staff roles are nested: SuperAdmin can do everything Admin can, Admin everything Cook can.
public enum UserRole
{
    Customer,
    Cook,
    Admin,
    SuperAdmin,
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

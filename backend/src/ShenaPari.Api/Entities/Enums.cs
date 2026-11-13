namespace ShenaPari.Api.Entities;

/// Staff roles are nested: SuperAdmin can do everything Admin can, Admin everything Cook can.
public enum UserRole
{
    Customer,
    Cook,
    Admin,
    SuperAdmin,
}

/// An order exists only once it is paid, then moves:
///   Paid → Accepted → Cooking → Ready → PickedUp
/// Cancelled is possible from Paid or Accepted (before cooking starts, money is refunded);
/// NotPickedUp from Ready (nobody came for the food, no refund).
public enum OrderStatus
{
    Paid,
    Accepted,
    Cooking,
    Ready,
    PickedUp,
    Cancelled,
    NotPickedUp,
}

/// Payment is simulated in the MVP: no real money moves.
public enum PaymentProvider
{
    GooglePay,
    ApplePay,
}

public enum PaymentStatus
{
    Paid,
    Refunded,
}

using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Orders;

/// The order lifecycle in one place. The server checks every transition instead of
/// trusting the client: Pending → Ready is rejected (409).
///
///   Pending → Accepted → Cooking → Ready → PickedUp
///      └──────────┴→ Cancelled
public static class OrderStatusRules
{
    private static readonly Dictionary<OrderStatus, OrderStatus[]> Allowed = new()
    {
        [OrderStatus.Pending] = [OrderStatus.Accepted, OrderStatus.Cancelled],
        [OrderStatus.Accepted] = [OrderStatus.Cooking, OrderStatus.Cancelled],
        [OrderStatus.Cooking] = [OrderStatus.Ready],
        [OrderStatus.Ready] = [OrderStatus.PickedUp],
        [OrderStatus.PickedUp] = [],
        [OrderStatus.Cancelled] = [],
    };

    public static bool CanMove(OrderStatus from, OrderStatus to) => Allowed[from].Contains(to);
}

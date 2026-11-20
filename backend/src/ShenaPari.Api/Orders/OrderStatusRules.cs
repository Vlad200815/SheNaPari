using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Orders;

/// The order lifecycle in one place. The server checks every transition instead of
/// trusting the client: Paid → Ready is rejected (409).
///
///   Paid → Accepted → Cooking → Ready → PickedUp
///     └───────┴─────────┴→ Cancelled  └→ NotPickedUp
///
/// The kitchen may cancel while cooking (it ran out of something); the
/// customer only until cooking starts (see CustomerCanCancel).
public static class OrderStatusRules
{
    private static readonly Dictionary<OrderStatus, OrderStatus[]> Allowed = new()
    {
        [OrderStatus.Paid] = [OrderStatus.Accepted, OrderStatus.Cancelled],
        [OrderStatus.Accepted] = [OrderStatus.Cooking, OrderStatus.Cancelled],
        [OrderStatus.Cooking] = [OrderStatus.Ready, OrderStatus.Cancelled],
        [OrderStatus.Ready] = [OrderStatus.PickedUp, OrderStatus.NotPickedUp],
        [OrderStatus.PickedUp] = [],
        [OrderStatus.Cancelled] = [],
        [OrderStatus.NotPickedUp] = [],
    };

    /// Minutes a cook may promise when accepting an order.
    public static readonly int[] EtaOptions = [5, 10, 15, 20];

    public static bool CanMove(OrderStatus from, OrderStatus to) => Allowed[from].Contains(to);

    /// The customer changes their mind: only before the kitchen starts cooking.
    public static bool CustomerCanCancel(OrderStatus s) => s is OrderStatus.Paid or OrderStatus.Accepted;

    /// Still on the kitchen's board.
    public static bool IsActive(OrderStatus s) =>
        s is OrderStatus.Paid or OrderStatus.Accepted or OrderStatus.Cooking or OrderStatus.Ready;
}

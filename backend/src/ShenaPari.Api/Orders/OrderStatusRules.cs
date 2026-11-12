using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Orders;

/// The order lifecycle in one place. The server checks every transition instead of
/// trusting the client: Paid → Ready is rejected (409).
///
///   Paid → Accepted → Cooking → Ready → PickedUp
///     └───────┴→ Cancelled         └→ NotPickedUp
public static class OrderStatusRules
{
    private static readonly Dictionary<OrderStatus, OrderStatus[]> Allowed = new()
    {
        [OrderStatus.Paid] = [OrderStatus.Accepted, OrderStatus.Cancelled],
        [OrderStatus.Accepted] = [OrderStatus.Cooking, OrderStatus.Cancelled],
        [OrderStatus.Cooking] = [OrderStatus.Ready],
        [OrderStatus.Ready] = [OrderStatus.PickedUp, OrderStatus.NotPickedUp],
        [OrderStatus.PickedUp] = [],
        [OrderStatus.Cancelled] = [],
        [OrderStatus.NotPickedUp] = [],
    };

    /// Minutes a cook may promise when accepting an order.
    public static readonly int[] EtaOptions = [5, 10, 15, 20];

    public static bool CanMove(OrderStatus from, OrderStatus to) => Allowed[from].Contains(to);

    /// Still on the kitchen's board.
    public static bool IsActive(OrderStatus s) =>
        s is OrderStatus.Paid or OrderStatus.Accepted or OrderStatus.Cooking or OrderStatus.Ready;
}

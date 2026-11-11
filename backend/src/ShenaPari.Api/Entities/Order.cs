namespace ShenaPari.Api.Entities;

public class Order
{
    public Guid Id { get; set; }

    /// Short human-readable number ("#42") shown to staff and the client.
    public int Number { get; set; }

    /// Random 128-bit secret; the only thing encoded into the pickup QR.
    public Guid PickupToken { get; set; }

    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public int BreakSlotId { get; set; }
    public BreakSlot BreakSlot { get; set; } = null!;
    public OrderStatus Status { get; set; } = OrderStatus.Pending;

    /// Calculated by the server from OrderItems; never trusted from the client.
    public decimal Total { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public List<OrderItem> Items { get; set; } = [];
}

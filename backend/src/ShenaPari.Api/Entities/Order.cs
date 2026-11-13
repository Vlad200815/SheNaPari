namespace ShenaPari.Api.Entities;

public class Order
{
    public Guid Id { get; set; }

    /// Short human-readable number ("#42") shown to staff and the client. Restarts every day.
    public int Number { get; set; }

    /// Random 128-bit secret; the only thing encoded into the pickup QR.
    public Guid PickupToken { get; set; }

    public Guid CustomerId { get; set; }
    public Customer Customer { get; set; } = null!;

    /// The break the client wants to pick the food up at; null = "as soon as possible".
    public int? BreakSlotId { get; set; }
    public BreakSlot? BreakSlot { get; set; }

    public OrderStatus Status { get; set; } = OrderStatus.Paid;

    /// Calculated by the server from OrderItems; never trusted from the client.
    public decimal Total { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    /// Set by the cook when accepting the order ("ready in ~15 min").
    public DateTimeOffset? EstimatedReadyAt { get; set; }

    /// When the order actually became Ready; the "not picked up" timer counts from here.
    public DateTimeOffset? ReadyAt { get; set; }

    public List<OrderItem> Items { get; set; } = [];
    public List<OrderStatusChange> StatusChanges { get; set; } = [];
    public List<Payment> Payments { get; set; } = [];
}

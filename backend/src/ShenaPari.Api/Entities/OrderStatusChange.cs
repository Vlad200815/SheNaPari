namespace ShenaPari.Api.Entities;

/// One line of an order's history: which status it got, when, who did it and why.
public class OrderStatusChange
{
    public int Id { get; set; }
    public Guid OrderId { get; set; }
    public OrderStatus Status { get; set; }

    /// The customer or employee who made the change; null = the system (timer).
    public Guid? ChangedByUserId { get; set; }
    public string? Reason { get; set; }
    public DateTimeOffset At { get; set; }
}

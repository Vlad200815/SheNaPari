namespace ShenaPari.Api.Entities;

/// A (simulated) payment for an order. Cancelling the order turns it into Refunded.
public class Payment
{
    public Guid Id { get; set; }
    public Guid OrderId { get; set; }
    public PaymentProvider Provider { get; set; }
    public decimal Amount { get; set; }
    public PaymentStatus Status { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? PaidAt { get; set; }
}

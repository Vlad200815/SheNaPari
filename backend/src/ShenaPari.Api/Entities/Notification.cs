namespace ShenaPari.Api.Entities;

/// A message for a customer, kept so the app can list it under the bell.
/// The same text goes out as a push; this copy survives a missed or
/// disabled push and works on iOS too.
public class Notification
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }

    /// The order it is about; tapping it in the app opens the order.
    public Guid? OrderId { get; set; }
    public required string Title { get; set; }
    public required string Body { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? ReadAt { get; set; }
}

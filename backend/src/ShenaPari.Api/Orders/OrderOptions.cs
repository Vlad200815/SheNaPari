namespace ShenaPari.Api.Orders;

/// Bound from the "Orders" section of appsettings.
public class OrderOptions
{
    /// A Ready order nobody picked up is closed as NotPickedUp after this many minutes.
    public int NotPickedUpAfterMinutes { get; init; } = 30;
}

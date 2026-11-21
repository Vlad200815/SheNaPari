namespace ShenaPari.Api.Orders;

/// Bound from the "Orders" section of appsettings.
public class OrderOptions
{
    /// A Ready order nobody picked up is closed as NotPickedUp after this many minutes.
    public int NotPickedUpAfterMinutes { get; init; } = 30;

    /// «How was it?»: the push and the home card come this long after pickup
    /// (time to eat).
    public int RatingAskAfterMinutes { get; init; } = 30;

    /// The home card stays this long after pickup, unless rated or dismissed.
    public int RatingCardHours { get; init; } = 24;

    /// A rating can be given or changed this long after pickup.
    public int RatingWindowDays { get; init; } = 3;
}

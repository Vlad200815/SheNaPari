using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Orders;

namespace ShenaPari.Api.Canteens;

public class CanteenService(AppDbContext db, OrderNotifier notifier)
{
    public async Task<CanteenDto> GetAsync()
    {
        var c = await db.Canteens.FirstAsync();
        return ToDto(c);
    }

    /// The kitchen's "we are overloaded" switch. Orders already placed are not affected.
    public async Task<CanteenDto> SetAcceptingAsync(bool isAccepting)
    {
        var c = await db.Canteens.FirstAsync();
        if (isAccepting) c.PausedAt = null;
        else if (c.IsAcceptingOrders) c.PausedAt = DateTimeOffset.UtcNow;
        c.IsAcceptingOrders = isAccepting;
        await db.SaveChangesAsync();

        var dto = ToDto(c);
        await notifier.CanteenChangedAsync(dto);
        return dto;
    }

    private static CanteenDto ToDto(Entities.Canteen c) =>
        new(Lang.Pick(c.Name, c.NameEn), c.IsAcceptingOrders, c.PausedAt);
}

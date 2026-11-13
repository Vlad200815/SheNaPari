using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Orders;

namespace ShenaPari.Api.Canteens;

public class CanteenService(AppDbContext db, OrderNotifier notifier)
{
    public async Task<CanteenDto> GetAsync()
    {
        var c = await db.Canteens.FirstAsync();
        return new CanteenDto(c.Name, c.IsAcceptingOrders);
    }

    /// The kitchen's "we are overloaded" switch. Orders already placed are not affected.
    public async Task<CanteenDto> SetAcceptingAsync(bool isAccepting)
    {
        var c = await db.Canteens.FirstAsync();
        c.IsAcceptingOrders = isAccepting;
        await db.SaveChangesAsync();

        var dto = new CanteenDto(c.Name, c.IsAcceptingOrders);
        await notifier.CanteenChangedAsync(dto);
        return dto;
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Orders;

/// Real-time channel at /hubs/orders. The client only listens; the server pushes:
///  - "OrderStatusChanged" to group user-{id} (the order's owner) and to "staff"
///  - "OrderCreated" to "staff"
[Authorize]
public class OrdersHub : Hub
{
    public const string StaffGroup = "staff";
    public static string UserGroup(Guid userId) => $"user-{userId}";

    public override async Task OnConnectedAsync()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, UserGroup(Context.User!.UserId()));
        if (!Context.User!.IsInRole(nameof(UserRole.Customer)))
            await Groups.AddToGroupAsync(Context.ConnectionId, StaffGroup);
        await base.OnConnectedAsync();
    }
}

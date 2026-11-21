using System.Net.Http.Json;
using Microsoft.AspNetCore.Http.Connections;
using Microsoft.AspNetCore.SignalR.Client;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Tests;

/// The menu over SignalR: open apps hear when a dish runs out or changes,
/// so nobody has to pull to refresh.
public class LiveMenuTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static readonly TimeSpan Wait = TimeSpan.FromSeconds(5);

    /// A customer's live connection, as the app opens it (?access_token=).
    private async Task<(HubConnection Hub, Task<MenuChangedEvent> Next)> ListenAsync()
    {
        var (_, auth) = await api.LoginCustomerAsync();
        var hub = new HubConnectionBuilder()
            .WithUrl(new Uri(api.Server.BaseAddress, "hubs/orders"), o =>
            {
                o.HttpMessageHandlerFactory = _ => api.Server.CreateHandler();
                o.Transports = HttpTransportType.LongPolling; // the test server has no WebSockets
                o.AccessTokenProvider = () => Task.FromResult<string?>(auth.AccessToken);
            })
            .Build();
        var next = new TaskCompletionSource<MenuChangedEvent>(TaskCreationOptions.RunContinuationsAsynchronously);
        hub.On<MenuChangedEvent>("MenuChanged", e => next.TrySetResult(e));
        await hub.StartAsync();
        return (hub, next.Task);
    }

    [Fact]
    public async Task Stop_list_switch_reaches_open_apps()
    {
        var cook = await api.LoginCookAsync();
        var (hub, next) = await ListenAsync();
        await using var _ = hub;

        await cook.PatchAsJsonAsync("/staff/dishes/12/availability", new SetAvailabilityDto(false));

        Assert.Equal(new MenuChangedEvent(12), await next.WaitAsync(Wait));
        await cook.PatchAsJsonAsync("/staff/dishes/12/availability", new SetAvailabilityDto(true));
    }

    [Fact]
    public async Task Admin_menu_edit_reaches_open_apps()
    {
        var admin = await api.LoginSuperAdminAsync();
        var (hub, next) = await ListenAsync();
        await using var _ = hub;

        var created = await admin.PostAsJsonAsync("/admin/dishes", new SaveDishDto(1, "Новий бургер", null, 100m, 200, 500));
        var dish = (await created.ReadResultAsync<AdminDishDto>()).Data!;

        Assert.Equal(new MenuChangedEvent(dish.Id), await next.WaitAsync(Wait));
        await admin.DeleteAsync($"/admin/dishes/{dish.Id}");
    }
}

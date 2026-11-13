using Microsoft.Extensions.Options;

namespace ShenaPari.Api.Orders;

/// Background timer: once a minute closes Ready orders that nobody picked up in time.
public class OrderExpiryService(
    IServiceProvider services, IOptions<OrderOptions> options, ILogger<OrderExpiryService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var limit = TimeSpan.FromMinutes(options.Value.NotPickedUpAfterMinutes);
        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1));
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                using var scope = services.CreateScope();
                var count = await scope.ServiceProvider.GetRequiredService<OrderService>()
                    .ExpireNotPickedUpAsync(limit);
                if (count > 0) logger.LogInformation("{Count} order(s) marked as not picked up", count);
            }
            catch (Exception e)
            {
                logger.LogError(e, "Order expiry check failed");
            }
        }
    }
}

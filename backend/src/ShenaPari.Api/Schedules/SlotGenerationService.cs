namespace ShenaPari.Api.Schedules;

/// Background timer: once an hour makes sure break slots exist for the coming week,
/// so the server can run for months without anyone restarting it.
public class SlotGenerationService(IServiceProvider services, ILogger<SlotGenerationService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromHours(1));
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                // A background service lives for the whole app; DbContext lives per scope.
                using var scope = services.CreateScope();
                await scope.ServiceProvider.GetRequiredService<ScheduleService>().EnsureSlotsAsync();
            }
            catch (Exception e)
            {
                logger.LogError(e, "Break slot generation failed");
            }
        }
    }
}

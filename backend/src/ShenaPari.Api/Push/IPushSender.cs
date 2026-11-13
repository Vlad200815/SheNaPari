namespace ShenaPari.Api.Push;

/// What the user sees in the notification, plus data the app uses to open the right screen.
public record PushMessage(string Title, string Body, Dictionary<string, string> Data);

/// Abstraction over a push provider, same idea as ISmsSender.
public interface IPushSender
{
    /// Sends to every device token. Returns the tokens the provider reported as dead
    /// (app uninstalled, token expired) so the caller can forget them.
    Task<IReadOnlyList<string>> SendAsync(IReadOnlyList<string> deviceTokens, PushMessage message);
}

/// Used when no Firebase key is configured: the server works, pushes are only logged.
public class LogPushSender(ILogger<LogPushSender> logger) : IPushSender
{
    public Task<IReadOnlyList<string>> SendAsync(IReadOnlyList<string> deviceTokens, PushMessage message)
    {
        logger.LogWarning("Push (not sent, Firebase is not configured) to {Count} device(s): {Title} — {Body}",
            deviceTokens.Count, message.Title, message.Body);
        return Task.FromResult<IReadOnlyList<string>>([]);
    }
}

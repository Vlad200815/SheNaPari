namespace ShenaPari.Api.Auth;

/// Abstraction over an SMS provider. MVP uses LogSmsSender; a real provider
/// (Twilio, TurboSMS, ...) is just another implementation registered in DI.
public interface ISmsSender
{
    Task SendAsync(string phone, string message);
}

public class LogSmsSender(ILogger<LogSmsSender> logger) : ISmsSender
{
    public Task SendAsync(string phone, string message)
    {
        logger.LogWarning("SMS to {Phone}: {Message}", phone, message);
        return Task.CompletedTask;
    }
}

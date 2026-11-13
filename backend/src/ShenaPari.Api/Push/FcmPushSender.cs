using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;

namespace ShenaPari.Api.Push;

/// Sends push notifications through Firebase Cloud Messaging (Android in the MVP).
public class FcmPushSender : IPushSender
{
    /// The Android app creates a notification channel with this id.
    public const string AndroidChannelId = "orders";

    private readonly FirebaseMessaging _messaging;
    private readonly ILogger<FcmPushSender> _logger;

    public FcmPushSender(string credentialsPath, ILogger<FcmPushSender> logger)
    {
        _logger = logger;
        var app = FirebaseApp.DefaultInstance ?? FirebaseApp.Create(new AppOptions
        {
            Credential = CredentialFactory.FromFile<ServiceAccountCredential>(credentialsPath).ToGoogleCredential(),
        });
        _messaging = FirebaseMessaging.GetMessaging(app);
    }

    public async Task<IReadOnlyList<string>> SendAsync(IReadOnlyList<string> deviceTokens, PushMessage message)
    {
        if (deviceTokens.Count == 0) return [];

        var response = await _messaging.SendEachForMulticastAsync(new MulticastMessage
        {
            // The library now prefers Firebase installation ids, but the Flutter plugin
            // (firebase_messaging.getToken) still hands out registration tokens, and they work.
#pragma warning disable CS0618
            Tokens = deviceTokens,
#pragma warning restore CS0618
            Notification = new Notification { Title = message.Title, Body = message.Body },
            Data = message.Data,
            Android = new AndroidConfig
            {
                Priority = Priority.High,
                Notification = new AndroidNotification { ChannelId = AndroidChannelId },
            },
        });

        var dead = new List<string>();
        for (var i = 0; i < response.Responses.Count; i++)
        {
            var r = response.Responses[i];
            if (r.IsSuccess) continue;
            var code = r.Exception?.MessagingErrorCode;
            if (code is MessagingErrorCode.Unregistered or MessagingErrorCode.InvalidArgument)
                dead.Add(deviceTokens[i]);
            else
                _logger.LogWarning(r.Exception, "Push to one device failed ({Code})", code);
        }
        _logger.LogInformation("Push \"{Title}\": {Ok} delivered to FCM, {Dead} dead token(s)",
            message.Title, response.SuccessCount, dead.Count);
        return dead;
    }
}

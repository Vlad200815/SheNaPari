using System.Collections.Concurrent;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Push;

namespace ShenaPari.Api.Tests;

/// Starts the real API in memory, on its own throw-away SQLite file.
/// SMS and push providers are replaced with fakes that remember what was "sent".
public class ApiFactory : WebApplicationFactory<Program>
{
    public const string SuperAdminEmail = "superadmin@shenapari.local";
    public const string SuperAdminPassword = "SuperAdmin123!";
    public const string CookEmail = "cook@shenapari.local";
    public const string CookPassword = "Cook12345!";

    private static int _phoneCounter = 1_000_000;
    private readonly string _dbPath = Path.Combine(Path.GetTempPath(), $"shenapari-test-{Guid.NewGuid():N}.db");

    public FakeSms Sms { get; } = new();
    public FakePush Push { get; } = new();

    /// Overridden by tests that need a specific setting (e.g. a tiny rate limit).
    protected virtual int AuthRequestsPerMinute => 100_000;

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development"); // seeds the test staff accounts and the hourly schedule
        builder.UseSetting("ConnectionStrings:Default", $"Data Source={_dbPath}");
        builder.UseSetting("Firebase:CredentialsPath", "not-configured"); // never talk to real Firebase
        builder.UseSetting("RateLimit:AuthRequestsPerMinute", AuthRequestsPerMinute.ToString());
        builder.ConfigureTestServices(services =>
        {
            services.AddSingleton<ISmsSender>(Sms);
            services.AddSingleton<IPushSender>(Push);
        });
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        foreach (var file in new[] { _dbPath, _dbPath + "-shm", _dbPath + "-wal" })
            if (File.Exists(file)) File.Delete(file);
    }

    /// A phone number no other test uses.
    public static string NewPhone() => $"+38067{Interlocked.Increment(ref _phoneCounter)}";

    /// Runs code against the database directly (to check what the API doesn't expose).
    public async Task<T> WithDbAsync<T>(Func<AppDbContext, Task<T>> action)
    {
        using var scope = Services.CreateScope();
        return await action(scope.ServiceProvider.GetRequiredService<AppDbContext>());
    }

    public async Task<T> WithServiceAsync<TService, T>(Func<TService, Task<T>> action) where TService : notnull
    {
        using var scope = Services.CreateScope();
        return await action(scope.ServiceProvider.GetRequiredService<TService>());
    }

    // ---------- logging in ----------

    /// Full phone login: request a code, read it from the fake SMS, verify. Optionally sets the name.
    public async Task<(HttpClient Client, AuthResponseDto Auth)> LoginCustomerAsync(string? phone = null, string? name = "Тест")
    {
        phone ??= NewPhone();
        var anonymous = CreateClient();
        (await anonymous.PostAsJsonAsync("/auth/otp/request", new OtpRequestDto(phone))).EnsureSuccessStatusCode();
        var response = await anonymous.PostAsJsonAsync("/auth/otp/verify", new OtpVerifyDto(phone, Sms.CodeFor(phone)));
        var auth = (await response.ReadResultAsync<AuthResponseDto>()).Data!;

        var client = Authorized(auth.AccessToken);
        if (name is not null) (await client.PatchAsJsonAsync("/me", new UpdateMeDto(name))).EnsureSuccessStatusCode();
        return (client, auth);
    }

    public async Task<HttpClient> LoginStaffAsync(string email, string password)
    {
        var response = await CreateClient().PostAsJsonAsync("/auth/staff/login", new StaffLoginDto(email, password));
        var auth = (await response.ReadResultAsync<AuthResponseDto>()).Data!;
        return Authorized(auth.AccessToken);
    }

    public Task<HttpClient> LoginCookAsync() => LoginStaffAsync(CookEmail, CookPassword);
    public Task<HttpClient> LoginSuperAdminAsync() => LoginStaffAsync(SuperAdminEmail, SuperAdminPassword);

    public HttpClient Authorized(string accessToken)
    {
        var client = CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        return client;
    }
}

/// The Result envelope as a client sees it.
public record ApiResult<T>(bool Succeeded, string? Message, T? Data, List<string> Errors);

public static class HttpExtensions
{
    public static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() },
    };

    public static async Task<ApiResult<T>> ReadResultAsync<T>(this HttpResponseMessage response) =>
        (await response.Content.ReadFromJsonAsync<ApiResult<T>>(Json))!;

    public static Task<HttpResponseMessage> PostJsonAsync<T>(this HttpClient client, string url, T body) =>
        client.PostAsJsonAsync(url, body, Json);

    public static Task<HttpResponseMessage> PutJsonAsync<T>(this HttpClient client, string url, T body) =>
        client.PutAsJsonAsync(url, body, Json);

    public static Task<HttpResponseMessage> PatchJsonAsync<T>(this HttpClient client, string url, T body) =>
        client.PatchAsJsonAsync(url, body, Json);

    public static async Task<T> GetDataAsync<T>(this HttpClient client, string url) =>
        (await (await client.GetAsync(url)).ReadResultAsync<T>()).Data!;
}

public class FakeSms : ISmsSender
{
    private readonly ConcurrentDictionary<string, string> _codes = new();

    public Task SendAsync(string phone, string message)
    {
        _codes[phone] = message[^6..]; // "ShenaPari code: 123456"
        return Task.CompletedTask;
    }

    public string CodeFor(string phone) => _codes[phone];
}

public class FakePush : IPushSender
{
    public ConcurrentQueue<(string DeviceToken, PushMessage Message)> Sent { get; } = new();

    public Task<IReadOnlyList<string>> SendAsync(IReadOnlyList<string> deviceTokens, PushMessage message)
    {
        foreach (var token in deviceTokens) Sent.Enqueue((token, message));
        return Task.FromResult<IReadOnlyList<string>>([]);
    }

    public List<string> TitlesFor(string deviceToken) =>
        Sent.Where(s => s.DeviceToken == deviceToken).Select(s => s.Message.Title).ToList();
}

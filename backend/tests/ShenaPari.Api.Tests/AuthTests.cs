using System.Net;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Tests;

public class AuthTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task New_customer_is_asked_for_a_name_only_once()
    {
        var phone = ApiFactory.NewPhone();

        var (client, first) = await api.LoginCustomerAsync(phone, name: null);
        Assert.True(first.IsNew);

        await client.PatchJsonAsync("/me", new UpdateMeDto("Влад"));
        var (_, second) = await api.LoginCustomerAsync(phone, name: null);
        Assert.False(second.IsNew);
    }

    [Fact]
    public async Task Wrong_code_is_rejected()
    {
        var phone = ApiFactory.NewPhone();
        var client = api.CreateClient();
        await client.PostJsonAsync("/auth/otp/request", new OtpRequestDto(phone));

        var wrong = api.Sms.CodeFor(phone) == "000000" ? "111111" : "000000";
        var response = await client.PostJsonAsync("/auth/otp/verify", new OtpVerifyDto(phone, wrong));

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Equal(["auth.invalid_code"], (await response.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Code_cannot_be_requested_twice_within_a_minute()
    {
        var phone = ApiFactory.NewPhone();
        var client = api.CreateClient();

        await client.PostJsonAsync("/auth/otp/request", new OtpRequestDto(phone));
        var again = await client.PostJsonAsync("/auth/otp/request", new OtpRequestDto(phone));

        Assert.Equal(HttpStatusCode.TooManyRequests, again.StatusCode);
        Assert.Equal(["auth.too_many_requests"], (await again.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Invalid_phone_is_rejected()
    {
        var response = await api.CreateClient().PostJsonAsync("/auth/otp/request", new OtpRequestDto("12345"));

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Equal(["auth.invalid_phone"], (await response.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Refresh_token_works_once_then_is_dead()
    {
        var (_, auth) = await api.LoginCustomerAsync();
        var client = api.CreateClient();

        var first = await client.PostJsonAsync("/auth/refresh", new RefreshDto(auth.RefreshToken));
        var reuse = await client.PostJsonAsync("/auth/refresh", new RefreshDto(auth.RefreshToken));

        Assert.Equal(HttpStatusCode.OK, first.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, reuse.StatusCode);
        Assert.Equal(["auth.invalid_token"], (await reuse.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Logout_kills_the_refresh_token()
    {
        var (client, auth) = await api.LoginCustomerAsync();

        await client.PostJsonAsync("/auth/logout", new RefreshDto(auth.RefreshToken));
        var refresh = await api.CreateClient().PostJsonAsync("/auth/refresh", new RefreshDto(auth.RefreshToken));

        Assert.Equal(HttpStatusCode.Unauthorized, refresh.StatusCode);
    }

    [Fact]
    public async Task Request_without_token_gets_401_in_the_envelope()
    {
        var response = await api.CreateClient().GetAsync("/categories");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        var result = await response.ReadResultAsync<object>();
        Assert.False(result.Succeeded);
        Assert.Equal(["common.unauthorized"], result.Errors);
    }

    [Fact]
    public async Task Staff_login_gives_the_same_error_for_unknown_email_and_wrong_password()
    {
        var client = api.CreateClient();

        var wrongPassword = await client.PostJsonAsync("/auth/staff/login", new StaffLoginDto(ApiFactory.CookEmail, "nope"));
        var unknownEmail = await client.PostJsonAsync("/auth/staff/login", new StaffLoginDto("nobody@x.y", "nope"));

        Assert.Equal(HttpStatusCode.Unauthorized, wrongPassword.StatusCode);
        Assert.Equal(["auth.invalid_credentials"], (await wrongPassword.ReadResultAsync<object>()).Errors);
        Assert.Equal(["auth.invalid_credentials"], (await unknownEmail.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Me_shows_phone_for_customers_and_email_for_staff()
    {
        var phone = ApiFactory.NewPhone();
        var (customer, _) = await api.LoginCustomerAsync(phone);
        var cook = await api.LoginCookAsync();

        var me = await customer.GetDataAsync<MeDto>("/me");
        var cookMe = await cook.GetDataAsync<MeDto>("/me");

        Assert.Equal((UserRole.Customer, phone, null), (me.Role, me.Phone, me.Email));
        Assert.Equal((UserRole.Cook, null, ApiFactory.CookEmail), (cookMe.Role, cookMe.Phone, cookMe.Email));
    }
}

public class RateLimitTests(RateLimitTests.StrictApi api) : IClassFixture<RateLimitTests.StrictApi>
{
    public class StrictApi : ApiFactory
    {
        protected override int AuthRequestsPerMinute => 3;
    }

    [Fact]
    public async Task Login_attempts_are_limited_per_minute()
    {
        var client = api.CreateClient();
        var codes = new List<HttpStatusCode>();
        for (var i = 0; i < 5; i++)
            codes.Add((await client.PostJsonAsync("/auth/staff/login", new StaffLoginDto("a@b.c", "x"))).StatusCode);

        Assert.Equal(3, codes.Count(c => c == HttpStatusCode.Unauthorized));
        Assert.Equal(2, codes.Count(c => c == HttpStatusCode.TooManyRequests));
    }
}

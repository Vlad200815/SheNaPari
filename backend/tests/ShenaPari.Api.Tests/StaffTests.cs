using System.Net;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Tests;

public class StaffTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    private static CreateEmployeeDto NewEmployee(UserRole role, string password = "Password123") =>
        new($"{Guid.NewGuid():N}@lntu.ua", password, "Працівник", role);

    [Fact]
    public async Task Customer_cannot_open_kitchen_or_admin_endpoints()
    {
        var (customer, _) = await api.LoginCustomerAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await customer.GetAsync("/staff/orders")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await customer.GetAsync("/admin/employees")).StatusCode);
    }

    [Fact]
    public async Task Cook_sees_the_kitchen_but_not_admin_endpoints_and_cannot_order()
    {
        var cook = await api.LoginCookAsync();

        Assert.Equal(HttpStatusCode.OK, (await cook.GetAsync("/staff/orders")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await cook.GetAsync("/admin/employees")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await cook.GetAsync("/admin/schedules")).StatusCode);
        var order = await cook.PostJsonAsync("/orders", new CreateOrderDto(null, PaymentProvider.GooglePay, []));
        Assert.Equal(HttpStatusCode.Forbidden, order.StatusCode);
    }

    [Fact]
    public async Task SuperAdmin_creates_admin_and_admin_creates_only_cooks()
    {
        var superAdmin = await api.LoginSuperAdminAsync();
        var adminDto = NewEmployee(UserRole.Admin);

        var created = await superAdmin.PostJsonAsync("/admin/employees", adminDto);
        Assert.Equal(HttpStatusCode.Created, created.StatusCode);

        var admin = await api.LoginStaffAsync(adminDto.Email, adminDto.Password);
        var cook = await admin.PostJsonAsync("/admin/employees", NewEmployee(UserRole.Cook));
        var anotherAdmin = await admin.PostJsonAsync("/admin/employees", NewEmployee(UserRole.Admin));

        Assert.Equal(HttpStatusCode.Created, cook.StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, anotherAdmin.StatusCode);
        Assert.Equal(["employee.not_allowed"], (await anotherAdmin.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Nobody_can_create_a_super_admin_or_a_weak_password()
    {
        var superAdmin = await api.LoginSuperAdminAsync();

        var asSuper = await superAdmin.PostJsonAsync("/admin/employees", NewEmployee(UserRole.SuperAdmin));
        var weak = await superAdmin.PostJsonAsync("/admin/employees", NewEmployee(UserRole.Cook, password: "123"));

        Assert.Equal(["employee.invalid_role"], (await asSuper.ReadResultAsync<object>()).Errors);
        Assert.Equal(["employee.weak_password"], (await weak.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Deactivated_cook_loses_access_at_once_and_cannot_log_in()
    {
        var superAdmin = await api.LoginSuperAdminAsync();
        var dto = NewEmployee(UserRole.Cook);
        var employee = (await (await superAdmin.PostJsonAsync("/admin/employees", dto)).ReadResultAsync<EmployeeDto>()).Data!;
        var cook = await api.LoginStaffAsync(dto.Email, dto.Password);
        Assert.Equal(HttpStatusCode.OK, (await cook.GetAsync("/staff/orders")).StatusCode);

        await superAdmin.PostAsync($"/admin/employees/{employee.Id}/deactivate", null);

        // the access token issued before deactivation is still not expired, yet it no longer works
        Assert.Equal(HttpStatusCode.Unauthorized, (await cook.GetAsync("/staff/orders")).StatusCode);
        var login = await api.CreateClient().PostJsonAsync("/auth/staff/login", new StaffLoginDto(dto.Email, dto.Password));
        Assert.Equal(HttpStatusCode.Forbidden, login.StatusCode);
        Assert.Equal(["auth.account_deactivated"], (await login.ReadResultAsync<object>()).Errors);
    }

    [Fact]
    public async Task Admin_resets_a_cooks_password()
    {
        var superAdmin = await api.LoginSuperAdminAsync();
        var dto = NewEmployee(UserRole.Cook);
        var employee = (await (await superAdmin.PostJsonAsync("/admin/employees", dto)).ReadResultAsync<EmployeeDto>()).Data!;

        await superAdmin.PostJsonAsync($"/admin/employees/{employee.Id}/password", new SetPasswordDto("BrandNew123"));

        var client = api.CreateClient();
        var oldPassword = await client.PostJsonAsync("/auth/staff/login", new StaffLoginDto(dto.Email, dto.Password));
        var newPassword = await client.PostJsonAsync("/auth/staff/login", new StaffLoginDto(dto.Email, "BrandNew123"));
        Assert.Equal(HttpStatusCode.Unauthorized, oldPassword.StatusCode);
        Assert.Equal(HttpStatusCode.OK, newPassword.StatusCode);
    }

    [Fact]
    public async Task Admin_cannot_deactivate_themselves_or_the_super_admin()
    {
        var superAdmin = await api.LoginSuperAdminAsync();
        var superId = (await superAdmin.GetDataAsync<MeDto>("/me")).Id;
        var adminDto = NewEmployee(UserRole.Admin);
        var adminId = (await (await superAdmin.PostJsonAsync("/admin/employees", adminDto)).ReadResultAsync<EmployeeDto>()).Data!.Id;
        var admin = await api.LoginStaffAsync(adminDto.Email, adminDto.Password);

        var self = await admin.PostAsync($"/admin/employees/{adminId}/deactivate", null);
        var boss = await admin.PostAsync($"/admin/employees/{superId}/deactivate", null);

        Assert.Equal(["employee.cannot_change_self"], (await self.ReadResultAsync<object>()).Errors);
        Assert.Equal(["employee.not_allowed"], (await boss.ReadResultAsync<object>()).Errors);
    }
}

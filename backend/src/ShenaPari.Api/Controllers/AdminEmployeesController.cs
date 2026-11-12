using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Employees;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("admin/employees")]
public class AdminEmployeesController(EmployeeService employees) : ControllerBase
{
    // GET /admin/employees
    [HttpGet]
    public async Task<ActionResult<Result<List<EmployeeDto>>>> GetAll() =>
        Result<List<EmployeeDto>>.Ok(await employees.GetAllAsync()).ToActionResult();

    // POST /admin/employees  { email, password, name, role: "Cook" | "Admin" }
    [HttpPost]
    public async Task<ActionResult<Result<EmployeeDto>>> Create(CreateEmployeeDto dto) =>
        (await employees.CreateAsync(User.Role(), dto)).ToActionResult(successStatus: 201);

    // POST /admin/employees/{id}/deactivate
    [HttpPost("{id:guid}/deactivate")]
    public async Task<ActionResult<Result<EmployeeDto>>> Deactivate(Guid id) =>
        (await employees.DeactivateAsync(User.UserId(), User.Role(), id)).ToActionResult();

    // POST /admin/employees/{id}/activate
    [HttpPost("{id:guid}/activate")]
    public async Task<ActionResult<Result<EmployeeDto>>> Activate(Guid id) =>
        (await employees.ActivateAsync(User.Role(), id)).ToActionResult();

    // POST /admin/employees/{id}/password  { password }
    [HttpPost("{id:guid}/password")]
    public async Task<ActionResult<Result<EmployeeDto>>> SetPassword(Guid id, SetPasswordDto dto) =>
        (await employees.SetPasswordAsync(User.Role(), id, dto.Password)).ToActionResult();
}

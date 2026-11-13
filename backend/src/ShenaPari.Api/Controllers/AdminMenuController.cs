using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Menu;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("admin")]
public class AdminMenuController(MenuAdminService menu) : ControllerBase
{
    // ---------- categories ----------

    [HttpGet("categories")]
    public async Task<ActionResult<Result<List<AdminCategoryDto>>>> GetCategories() =>
        Result<List<AdminCategoryDto>>.Ok(await menu.GetCategoriesAsync()).ToActionResult();

    [HttpPost("categories")]
    public async Task<ActionResult<Result<AdminCategoryDto>>> CreateCategory(SaveCategoryDto dto) =>
        (await menu.CreateCategoryAsync(dto)).ToActionResult(successStatus: 201);

    [HttpPut("categories/{id:int}")]
    public async Task<ActionResult<Result<AdminCategoryDto>>> UpdateCategory(int id, SaveCategoryDto dto) =>
        (await menu.UpdateCategoryAsync(id, dto)).ToActionResult();

    // Only an empty category can be deleted.
    [HttpDelete("categories/{id:int}")]
    public async Task<ActionResult<Result<object?>>> DeleteCategory(int id) =>
        (await menu.DeleteCategoryAsync(id)).ToActionResult();

    // ---------- dishes ----------

    [HttpGet("dishes")]
    public async Task<ActionResult<Result<List<AdminDishDto>>>> GetDishes() =>
        Result<List<AdminDishDto>>.Ok(await menu.GetDishesAsync()).ToActionResult();

    [HttpPost("dishes")]
    public async Task<ActionResult<Result<AdminDishDto>>> CreateDish(SaveDishDto dto) =>
        (await menu.CreateDishAsync(dto)).ToActionResult(successStatus: 201);

    [HttpPut("dishes/{id:int}")]
    public async Task<ActionResult<Result<AdminDishDto>>> UpdateDish(int id, SaveDishDto dto) =>
        (await menu.UpdateDishAsync(id, dto)).ToActionResult();

    // A dish that appears in past orders can't be deleted; set isAvailable = false instead.
    [HttpDelete("dishes/{id:int}")]
    public async Task<ActionResult<Result<object?>>> DeleteDish(int id) =>
        (await menu.DeleteDishAsync(id)).ToActionResult();

    // POST /admin/dishes/{id}/image — multipart form with one file (JPEG, PNG or WebP, up to 5 MB)
    [HttpPost("dishes/{id:int}/image")]
    public async Task<ActionResult<Result<AdminDishDto>>> UploadDishImage(int id, IFormFile? file) =>
        (await menu.SetDishImageAsync(id, file)).ToActionResult();
}

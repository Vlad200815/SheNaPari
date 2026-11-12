using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize]
[Route("categories")]
public class CategoriesController(AppDbContext db) : ControllerBase
{
    // GET /categories
    [HttpGet]
    public async Task<ActionResult<Result<List<CategoryDto>>>> GetAll()
    {
        var categories = await db.Categories
            .OrderBy(c => c.SortOrder)
            .Select(c => new CategoryDto(c.Id, c.Name))
            .ToListAsync();
        return Result<List<CategoryDto>>.Ok(categories).ToActionResult();
    }
}

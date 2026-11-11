using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Route("categories")]
// [Authorize] will be added here once auth is ready.
public class CategoriesController(AppDbContext db) : ControllerBase
{
    // GET /categories
    [HttpGet]
    public async Task<List<CategoryDto>> GetAll() =>
        await db.Categories
            .OrderBy(c => c.SortOrder)
            .Select(c => new CategoryDto(c.Id, c.Name))
            .ToListAsync();
}

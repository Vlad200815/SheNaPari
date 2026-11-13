using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;
using ShenaPari.Api.Entities;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize]
[Route("dishes")]
public class DishesController(AppDbContext db) : ControllerBase
{
    // GET /dishes?categoryId=2&popular=true — both filters optional
    [HttpGet]
    public async Task<ActionResult<Result<List<DishDto>>>> GetAll(int? categoryId, bool? popular)
    {
        // IQueryable = a query that is only *described* here; SQL runs at ToListAsync().
        IQueryable<Dish> query = db.Dishes.Where(d => d.IsAvailable);
        if (categoryId is not null) query = query.Where(d => d.CategoryId == categoryId);
        if (popular is not null) query = query.Where(d => d.IsPopular == popular);

        var dishes = await query.OrderBy(d => d.CategoryId).ThenBy(d => d.Name).ToListAsync();
        return Result<List<DishDto>>.Ok(dishes.Select(ToDto).ToList()).ToActionResult();
    }

    // GET /dishes/5
    [HttpGet("{id:int}")]
    public async Task<ActionResult<Result<DishDto>>> GetById(int id)
    {
        var dish = await db.Dishes.FirstOrDefaultAsync(d => d.Id == id && d.IsAvailable);
        Result<DishDto> result = dish is null ? MenuErrors.DishNotFound : ToDto(dish);
        return result.ToActionResult();
    }

    private static DishDto ToDto(Dish d) =>
        new(d.Id, d.CategoryId, d.Name, d.Description, d.Price, d.WeightG, d.Kcal, d.ImageUrl, d.IsPopular);
}

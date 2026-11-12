using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Auth;
using ShenaPari.Api.Common;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Cook)]
[Route("staff/dishes")]
public class StaffDishesController(AppDbContext db) : ControllerBase
{
    // GET /staff/dishes — the whole menu, hidden dishes included
    [HttpGet]
    public async Task<ActionResult<Result<List<StaffDishDto>>>> GetAll()
    {
        var dishes = await db.Dishes
            .OrderBy(d => d.CategoryId).ThenBy(d => d.Name)
            .Select(d => new StaffDishDto(d.Id, d.CategoryId, d.Name, d.IsAvailable))
            .ToListAsync();
        return Result<List<StaffDishDto>>.Ok(dishes).ToActionResult();
    }

    // PATCH /staff/dishes/{id}/availability  { "isAvailable": false } — stop-list: "we ran out of borscht"
    [HttpPatch("{id:int}/availability")]
    public async Task<ActionResult<Result<StaffDishDto>>> SetAvailability(int id, SetAvailabilityDto dto)
    {
        var dish = await db.Dishes.FindAsync(id);
        if (dish is null) return Result<StaffDishDto>.Fail(MenuErrors.DishNotFound).ToActionResult();

        dish.IsAvailable = dto.IsAvailable;
        await db.SaveChangesAsync();
        return Result<StaffDishDto>.Ok(new StaffDishDto(dish.Id, dish.CategoryId, dish.Name, dish.IsAvailable))
            .ToActionResult();
    }
}

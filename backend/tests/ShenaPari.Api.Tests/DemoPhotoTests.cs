using System.Net;
using Microsoft.EntityFrameworkCore;
using ShenaPari.Api.Data;
using ShenaPari.Api.Dtos;

namespace ShenaPari.Api.Tests;

public class DemoPhotoTests(ApiFactory api) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task Every_demo_dish_has_a_photo_that_the_server_serves()
    {
        var (customer, _) = await api.LoginCustomerAsync();

        var dishes = await customer.GetDataAsync<List<DishDto>>("/dishes");

        Assert.NotEmpty(dishes);
        foreach (var dish in dishes)
        {
            Assert.StartsWith("/images/menu/", dish.ImageUrl);
            var photo = await api.CreateClient().GetAsync(dish.ImageUrl);
            Assert.Equal(HttpStatusCode.OK, photo.StatusCode);
            Assert.Equal("image/jpeg", photo.Content.Headers.ContentType?.MediaType);
        }
    }

    [Fact]
    public async Task An_older_database_gets_the_photos_but_an_uploaded_photo_stays()
    {
        const string uploaded = "/images/dishes/2-own.jpg";
        await api.WithDbAsync(async db =>
        {
            await db.Dishes.Where(d => d.Id == 1).ExecuteUpdateAsync(s => s.SetProperty(d => d.ImageUrl, (string?)null));
            return await db.Dishes.Where(d => d.Id == 2).ExecuteUpdateAsync(s => s.SetProperty(d => d.ImageUrl, uploaded));
        });

        await DbSeeder.SeedAsync(api.Services);

        var urls = await api.WithDbAsync(db =>
            db.Dishes.Where(d => d.Id <= 2).OrderBy(d => d.Id).Select(d => d.ImageUrl).ToListAsync());
        Assert.Equal("/images/menu/cheeseburger.jpg", urls[0]);
        Assert.Equal(uploaded, urls[1]);

        // the class shares one database: put the demo photo back
        await api.WithDbAsync(db => db.Dishes.Where(d => d.Id == 2)
            .ExecuteUpdateAsync(s => s.SetProperty(d => d.ImageUrl, "/images/menu/chicken-burger.jpg")));
    }
}

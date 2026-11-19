using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShenaPari.Api.Migrations
{
    /// <inheritdoc />
    public partial class DishNameEn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "NameEnSnapshot",
                table: "OrderItems",
                type: "TEXT",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "Dishes",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "Dishes",
                type: "TEXT",
                nullable: true);

            // A database seeded before these columns existed gets the demo texts too.
            foreach (var (uk, en, descriptionEn) in new (string, string, string)[]
            {
                ("Чизбургер", "Cheeseburger", "Beef patty, cheddar, pickles, sauce"),
                ("Бургер з куркою", "Chicken burger", "Breaded chicken fillet, lettuce, tomato, sauce"),
                ("Подвійний бургер", "Double burger", "Two beef patties, double cheese, bacon"),
                ("Хот-дог класичний", "Classic hot dog", "Sausage, ketchup, mustard, pickled onion"),
                ("Хот-дог із сиром", "Cheese hot dog", "Sausage, cheese sauce, crispy onion"),
                ("Французький хот-дог", "French hot dog", "Sausage in a baguette, garlic sauce"),
                ("Багет із шинкою і сиром", "Ham and cheese baguette", "Ham, cheese, lettuce, tomato"),
                ("Багет із куркою", "Chicken baguette", "Chicken fillet, vegetables, Caesar dressing"),
                ("Багет із тунцем", "Tuna baguette", "Tuna, egg, cucumber, mayonnaise"),
                ("Борщ український", "Ukrainian borscht", "With sour cream and a garlic bun"),
                ("Суп курячий з локшиною", "Chicken noodle soup", "Homemade noodles, herbs"),
                ("Вареники з картоплею", "Potato varenyky", "With fried onion and sour cream"),
                ("Котлета по-київськи", "Chicken Kyiv", "With mashed potatoes"),
                ("Сирник", "Syrnyk", "With sour cream"),
                ("Пиріжок з вишнею", "Cherry pie", null),
                ("Круасан", "Croissant", "Butter"),
                ("Чай чорний", "Black tea", null),
                ("Кава американо", "Americano", null),
                ("Компот", "Kompot", "Dried fruit"),
            })
            {
                migrationBuilder.UpdateData("Dishes", "Name", uk,
                    ["NameEn", "DescriptionEn"], [en, descriptionEn]);
            }

            // Past orders show the English names too.
            migrationBuilder.Sql(
                "UPDATE OrderItems SET NameEnSnapshot = (SELECT NameEn FROM Dishes WHERE Dishes.Id = OrderItems.DishId)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "NameEnSnapshot",
                table: "OrderItems");

            migrationBuilder.DropColumn(
                name: "DescriptionEn",
                table: "Dishes");

            migrationBuilder.DropColumn(
                name: "NameEn",
                table: "Dishes");
        }
    }
}

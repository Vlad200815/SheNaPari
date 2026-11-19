using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShenaPari.Api.Migrations
{
    /// <inheritdoc />
    public partial class DishNutrition : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CarbsG",
                table: "Dishes",
                type: "INTEGER",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "FatG",
                table: "Dishes",
                type: "INTEGER",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsVegan",
                table: "Dishes",
                type: "INTEGER",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "ProteinG",
                table: "Dishes",
                type: "INTEGER",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "SpicyLevel",
                table: "Dishes",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            // A database seeded before these columns existed gets the demo numbers too.
            foreach (var (name, protein, fat, carbs, spicy, vegan) in new (string, int, int, int, int, bool)[]
            {
                ("Чизбургер", 26, 24, 40, 0, false),
                ("Бургер з куркою", 32, 21, 48, 0, false),
                ("Подвійний бургер", 44, 44, 46, 0, false),
                ("Хот-дог класичний", 13, 22, 35, 1, false),
                ("Хот-дог із сиром", 16, 26, 38, 0, false),
                ("Французький хот-дог", 14, 23, 39, 0, false),
                ("Багет із шинкою і сиром", 22, 16, 50, 0, false),
                ("Багет із куркою", 28, 16, 51, 0, false),
                ("Багет із тунцем", 24, 18, 45, 0, false),
                ("Борщ український", 7, 9, 25, 0, false),
                ("Суп курячий з локшиною", 11, 5, 18, 0, false),
                ("Вареники з картоплею", 10, 14, 61, 0, false),
                ("Котлета по-київськи", 26, 30, 36, 0, false),
                ("Сирник", 15, 11, 25, 0, false),
                ("Пиріжок з вишнею", 4, 8, 36, 0, false),
                ("Круасан", 5, 16, 29, 0, false),
                ("Чай чорний", 0, 0, 1, 0, true),
                ("Кава американо", 0, 0, 2, 0, true),
                ("Компот", 0, 0, 22, 0, true),
            })
            {
                migrationBuilder.UpdateData("Dishes", "Name", name,
                    ["ProteinG", "FatG", "CarbsG", "SpicyLevel", "IsVegan"],
                    [protein, fat, carbs, spicy, vegan]);
            }

            // One vegan and spicy dish, so both marks show up in the demo menu.
            migrationBuilder.Sql("""
                INSERT INTO Dishes (CategoryId, Name, Description, NameEn, DescriptionEn, Price, WeightG, Kcal,
                                    ProteinG, FatG, CarbsG, SpicyLevel, IsVegan, IsAvailable, IsPopular)
                SELECT Id, 'Фалафель у піті', 'Фалафель, хумус, овочі, гострий соус', 'Falafel pita',
                       'Falafel, hummus, vegetables, hot sauce', 95.0, 260, 480, 16, 20, 58, 2, 1, 1, 0
                FROM Categories
                WHERE Name = 'Багети' AND NOT EXISTS (SELECT 1 FROM Dishes WHERE Name = 'Фалафель у піті');
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CarbsG",
                table: "Dishes");

            migrationBuilder.DropColumn(
                name: "FatG",
                table: "Dishes");

            migrationBuilder.DropColumn(
                name: "IsVegan",
                table: "Dishes");

            migrationBuilder.DropColumn(
                name: "ProteinG",
                table: "Dishes");

            migrationBuilder.DropColumn(
                name: "SpicyLevel",
                table: "Dishes");
        }
    }
}

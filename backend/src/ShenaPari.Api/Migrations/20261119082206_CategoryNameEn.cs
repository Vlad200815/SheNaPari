using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShenaPari.Api.Migrations
{
    /// <inheritdoc />
    public partial class CategoryNameEn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "Categories",
                type: "TEXT",
                maxLength: 100,
                nullable: true);

            // A database seeded before this column existed gets the demo names too.
            foreach (var (uk, en) in new[]
            {
                ("Бургери", "Burgers"), ("Хот-доги", "Hot dogs"), ("Багети", "Baguettes"),
                ("Гарячі страви", "Hot meals"), ("Випічка", "Pastries"), ("Напої", "Drinks"),
            })
            {
                migrationBuilder.UpdateData("Categories", "Name", uk, "NameEn", en);
            }
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "NameEn",
                table: "Categories");
        }
    }
}

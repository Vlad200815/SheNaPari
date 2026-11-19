using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShenaPari.Api.Migrations
{
    /// <inheritdoc />
    public partial class CanteenNameEn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "Canteens",
                type: "TEXT",
                nullable: true);

            // The canteen seeded before this column existed.
            migrationBuilder.UpdateData("Canteens", "Name", "Їдальня, корпус 1", "NameEn", "Canteen, building 1");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "NameEn",
                table: "Canteens");
        }
    }
}

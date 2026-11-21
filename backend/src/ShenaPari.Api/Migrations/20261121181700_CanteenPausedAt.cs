using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShenaPari.Api.Migrations
{
    /// <inheritdoc />
    public partial class CanteenPausedAt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "PausedAt",
                table: "Canteens",
                type: "INTEGER",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PausedAt",
                table: "Canteens");
        }
    }
}

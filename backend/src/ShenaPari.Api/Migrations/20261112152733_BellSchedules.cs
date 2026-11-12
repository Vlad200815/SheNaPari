using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShenaPari.Api.Migrations
{
    /// <inheritdoc />
    public partial class BellSchedules : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OrderDeadline",
                table: "BreakSlots");

            migrationBuilder.CreateTable(
                name: "BellSchedules",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BellSchedules", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "BellScheduleBreak",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    BellScheduleId = table.Column<int>(type: "INTEGER", nullable: false),
                    Start = table.Column<TimeOnly>(type: "TEXT", nullable: false),
                    End = table.Column<TimeOnly>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BellScheduleBreak", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BellScheduleBreak_BellSchedules_BellScheduleId",
                        column: x => x.BellScheduleId,
                        principalTable: "BellSchedules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BreakSlots_StartsAt",
                table: "BreakSlots",
                column: "StartsAt");

            migrationBuilder.CreateIndex(
                name: "IX_BellScheduleBreak_BellScheduleId",
                table: "BellScheduleBreak",
                column: "BellScheduleId");

            migrationBuilder.CreateIndex(
                name: "IX_BellSchedules_Name",
                table: "BellSchedules",
                column: "Name",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BellScheduleBreak");

            migrationBuilder.DropTable(
                name: "BellSchedules");

            migrationBuilder.DropIndex(
                name: "IX_BreakSlots_StartsAt",
                table: "BreakSlots");

            migrationBuilder.AddColumn<long>(
                name: "OrderDeadline",
                table: "BreakSlots",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0L);
        }
    }
}

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShenaPari.Api.Migrations
{
    /// <inheritdoc />
    public partial class SessionPushToken : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PushToken",
                table: "RefreshTokens",
                type: "TEXT",
                maxLength: 500,
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_PushToken",
                table: "RefreshTokens",
                column: "PushToken");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_RefreshTokens_PushToken",
                table: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "PushToken",
                table: "RefreshTokens");
        }
    }
}

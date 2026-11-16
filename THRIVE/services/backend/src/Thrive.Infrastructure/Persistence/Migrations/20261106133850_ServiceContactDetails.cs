using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Thrive.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ServiceContactDetails : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "university_services",
                type: "character varying(254)",
                maxLength: 254,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Phone",
                table: "university_services",
                type: "character varying(32)",
                maxLength: 32,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Source",
                table: "university_services",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Specialty",
                table: "university_services",
                type: "character varying(40)",
                maxLength: 40,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Email",
                table: "university_services");

            migrationBuilder.DropColumn(
                name: "Phone",
                table: "university_services");

            migrationBuilder.DropColumn(
                name: "Source",
                table: "university_services");

            migrationBuilder.DropColumn(
                name: "Specialty",
                table: "university_services");
        }
    }
}

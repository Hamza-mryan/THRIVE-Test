using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Thrive.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class StudentActivityAndScreeningAudit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "activity_audit_events",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SubjectId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Action = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    ResourceId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    OccurredAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_activity_audit_events", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "daily_moods",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SubjectId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Day = table.Column<DateOnly>(type: "date", nullable: false),
                    Value = table.Column<int>(type: "integer", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_daily_moods", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_daily_moods_UniversityId_SubjectId_Day",
                table: "daily_moods",
                columns: new[] { "UniversityId", "SubjectId", "Day" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "activity_audit_events");

            migrationBuilder.DropTable(
                name: "daily_moods");
        }
    }
}

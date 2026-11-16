using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Thrive.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class FunctionalDevelopmentMvp : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "guide_resources",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Slug = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    TitleAr = table.Column<string>(type: "text", nullable: false),
                    TitleEn = table.Column<string>(type: "text", nullable: false),
                    SummaryAr = table.Column<string>(type: "text", nullable: false),
                    SummaryEn = table.Column<string>(type: "text", nullable: false),
                    BodyAr = table.Column<string>(type: "text", nullable: false),
                    BodyEn = table.Column<string>(type: "text", nullable: false),
                    Category = table.Column<string>(type: "text", nullable: false),
                    Source = table.Column<string>(type: "text", nullable: false),
                    ReviewedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Version = table.Column<string>(type: "text", nullable: false),
                    IsDemo = table.Column<bool>(type: "boolean", nullable: false),
                    Published = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_guide_resources", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "screening_sessions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SubjectId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    InstrumentCode = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    InstrumentVersion = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    StartedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CompletedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    RawScore = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_screening_sessions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "university_services",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Level = table.Column<string>(type: "text", nullable: false),
                    NameAr = table.Column<string>(type: "text", nullable: false),
                    NameEn = table.Column<string>(type: "text", nullable: false),
                    DescriptionAr = table.Column<string>(type: "text", nullable: false),
                    DescriptionEn = table.Column<string>(type: "text", nullable: false),
                    HoursAr = table.Column<string>(type: "text", nullable: false),
                    HoursEn = table.Column<string>(type: "text", nullable: false),
                    LocationAr = table.Column<string>(type: "text", nullable: false),
                    LocationEn = table.Column<string>(type: "text", nullable: false),
                    BookingMethod = table.Column<string>(type: "text", nullable: false),
                    ContactUrl = table.Column<string>(type: "text", nullable: true),
                    IsDemo = table.Column<bool>(type: "boolean", nullable: false),
                    Verified = table.Column<bool>(type: "boolean", nullable: false),
                    Active = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_university_services", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "screening_answers",
                columns: table => new
                {
                    SessionId = table.Column<Guid>(type: "uuid", nullable: false),
                    ItemCode = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Value = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_screening_answers", x => new { x.SessionId, x.ItemCode });
                    table.ForeignKey(
                        name: "FK_screening_answers_screening_sessions_SessionId",
                        column: x => x.SessionId,
                        principalTable: "screening_sessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "referrals",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SubjectId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ServiceId = table.Column<Guid>(type: "uuid", nullable: false),
                    ServiceNameAr = table.Column<string>(type: "text", nullable: false),
                    ServiceNameEn = table.Column<string>(type: "text", nullable: false),
                    Level = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsDemo = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_referrals", x => x.Id);
                    table.ForeignKey(
                        name: "FK_referrals_university_services_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "university_services",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_guide_resources_UniversityId_Slug",
                table: "guide_resources",
                columns: new[] { "UniversityId", "Slug" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_referrals_ServiceId",
                table: "referrals",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_referrals_UniversityId_SubjectId_ServiceId",
                table: "referrals",
                columns: new[] { "UniversityId", "SubjectId", "ServiceId" },
                unique: true,
                filter: "\"Status\" IN ('Requested', 'Received', 'Scheduled')");

            migrationBuilder.CreateIndex(
                name: "IX_screening_sessions_UniversityId_SubjectId_StartedAtUtc",
                table: "screening_sessions",
                columns: new[] { "UniversityId", "SubjectId", "StartedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_university_services_UniversityId",
                table: "university_services",
                column: "UniversityId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "guide_resources");

            migrationBuilder.DropTable(
                name: "referrals");

            migrationBuilder.DropTable(
                name: "screening_answers");

            migrationBuilder.DropTable(
                name: "university_services");

            migrationBuilder.DropTable(
                name: "screening_sessions");
        }
    }
}

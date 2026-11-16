using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Thrive.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialConsent : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "consent_decisions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SubjectId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PolicyVersion = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    ServiceUse = table.Column<bool>(type: "boolean", nullable: false),
                    ResearchUse = table.Column<bool>(type: "boolean", nullable: false),
                    RecordedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_consent_decisions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "consent_audit_events",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DecisionId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubjectId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    UniversityId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Action = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    OccurredAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_consent_audit_events", x => x.Id);
                    table.ForeignKey(
                        name: "FK_consent_audit_events_consent_decisions_DecisionId",
                        column: x => x.DecisionId,
                        principalTable: "consent_decisions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_consent_audit_events_DecisionId",
                table: "consent_audit_events",
                column: "DecisionId");

            migrationBuilder.CreateIndex(
                name: "IX_consent_decisions_UniversityId_SubjectId_RecordedAtUtc",
                table: "consent_decisions",
                columns: new[] { "UniversityId", "SubjectId", "RecordedAtUtc" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "consent_audit_events");

            migrationBuilder.DropTable(
                name: "consent_decisions");
        }
    }
}

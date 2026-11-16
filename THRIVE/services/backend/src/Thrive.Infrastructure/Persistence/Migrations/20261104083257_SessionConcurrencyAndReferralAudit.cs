using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Thrive.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SessionConcurrencyAndReferralAudit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Revision",
                table: "screening_sessions",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "referral_status_events",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ReferralId = table.Column<Guid>(type: "uuid", nullable: false),
                    ActorSubjectId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Status = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    OccurredAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_referral_status_events", x => x.Id);
                    table.ForeignKey(
                        name: "FK_referral_status_events_referrals_ReferralId",
                        column: x => x.ReferralId,
                        principalTable: "referrals",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_referral_status_events_ReferralId",
                table: "referral_status_events",
                column: "ReferralId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "referral_status_events");

            migrationBuilder.DropColumn(
                name: "Revision",
                table: "screening_sessions");
        }
    }
}

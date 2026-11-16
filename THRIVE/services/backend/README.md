# THRIVE Backend

This copy is **THRIVE Test**. Use only the owned test cluster and scripts described in [the isolation report](../../docs/TEST_ISOLATION.ar.md). Live identity-provider settings are rejected in this copy.

ASP.NET Core API on pinned .NET SDK `10.0.403`. The connected development MVP includes onboarding, consent management, a nonclinical usability questionnaire, published product guides, service directories, referrals, and role-gated university administration. Clinical instruments, institution identity integration, reviewed operational directories and external notifications require institution configuration and are not represented as live services.

## Structure

The PDF-coverage update adds `/me/activity`, `/me/moods?from=YYYY-MM-DD&to=YYYY-MM-DD`, and PUT/DELETE `/me/moods/{day}`. These student-only routes require current service consent, enforce ownership/university scope, and never feed clinical scoring or reports. `StudentActivityAndScreeningAudit` creates daily mood and audit tables; screening start/answer-save/submit now add minimal audit events atomically with writes, without answer/score payloads.

- `src/Thrive.Api`: thin HTTP routes, authentication/authorization, response mapping, error filters, health/readiness and OpenAPI.
- `src/Thrive.Application`: use cases for consent, screening, catalog and referrals; persistence ports and validation.
- `src/Thrive.Domain`: consent, screening sessions/answers, catalog and referral records, pure transition rules, and UTC timestamp invariants.
- `src/Thrive.Infrastructure`: scoped EF stores, PostgreSQL model/migrations and explicitly gated development catalog seed.
- `src/Thrive.Contracts`: public request/response records, separate from EF entities.
- `tests/Thrive.Tests`: rule and authenticated API integration tests using relational SQLite, plus stale-update concurrency and OpenAPI checks.

Dependency direction remains inward. Application does not reference EF; Domain has no HTTP or infrastructure dependencies. The API returns mapped contracts, never persistence entities containing subject/university identifiers.

## Build and checks

Run from this directory with a compatible SDK, or add the portable SDK to the current process PATH:

```powershell
. ../../scripts/lib/GeneratedWorkspace.ps1
Initialize-ThriveTestGeneratedWorkspace (Resolve-Path ../..).Path -Component Backend
$env:PATH = "C:/Users/hmztm/.cache/thrive-toolchains/dotnet;" + $env:PATH
dotnet restore --locked-mode
dotnet build --configuration Release --no-restore
dotnet test --configuration Release --no-build
dotnet format --verify-no-changes --no-restore
```

NuGet packages and SDK are pinned; lockfiles are checked into source. No production data belongs in development or tests.

## Database and local launch

From the `THRIVE` root:

```powershell
./scripts/initialize-local.ps1
./scripts/start-database.ps1
./scripts/start-backend.ps1 -ApplyMigrations -EnableDevelopmentIdentity
```

The helper reads ignored local credentials without printing them. It opts into synthetic identity only when requested. Without that flag, protected routes deny access. This test copy rejects external identity-provider configuration.

Use scripts/start-backend.ps1 -ApplyMigrations from the THRIVE Test root. It verifies the actual server data directory, database, role and port before migration. Do not run migrations with copied or shared connection settings.

Migrations are the schema authority. They include consent/audit, sessions/answers, guide resources, university services, referrals, referral status events, a partial unique index for duplicate open referrals, and a session concurrency revision. Startup does not silently migrate a production database.

- `/health/live` reports process liveness without a database dependency.
- `/health/ready` requires database connectivity and no pending migrations; otherwise503. Responses omit connection/provider details.
- `/openapi/v1.json` is available in Development. Re-export through `THRIVE/scripts/export-openapi.ps1` after API changes.

## Identity and access

`DevelopmentIdentity:Enabled` is false by default and honored only in Development. `POST /api/v1/development/session` accepts fixed synthetic personas:

| Persona | Role | Scope |
|---|---|---|
| student-a | Student | demo-university |
| student-b | Student | demo-university |
| student-other-university | Student | demo-other-university |
| admin | UniversityAdmin | demo-university |
| admin-other-university | UniversityAdmin | demo-other-university |

Tokens use an in-memory random signing key and expire after an hour; a server restart invalidates them. They are for development, not university sign-in. Clients must not persist tokens in browser storage or logs.

Production JWT/OIDC configuration uses `Identity__Authority` and `Identity__Audience`, HTTPS metadata, and trusted claims `sub`, `university_id`, `role` (Student or UniversityAdmin), plus optional `name`. Claim-to-university membership must be established with the institution before operational use. Unconfigured authentication fails closed. `GET /me` returns the role and development marker for client presentation, while every functional endpoint enforces its own policy server-side.

Student functional endpoints require current service consent. Research is always independent. Consent endpoints remain available before service consent. `POST /me/consents/withdraw` appends a service=false/research=false decision and audit event, immediately blocking functional access until service consent is accepted again. Withdrawal is not a data-erasure API; institutional retention/deletion policy remains a separate release requirement.

Administration requires UniversityAdmin. Student data is scoped by both university and subject; admin catalog/referral operations by university. Administration referrals expose status/service data without student identity, questionnaire answers or scores. Aggregate sensitive counts below5 are null; no individual-health drilldown is provided.

Local Development CORS permits only `http://localhost:5400` and `http://localhost:4300`. Production has no permissive default CORS. TLS/forwarded headers and deployment hosts need environment configuration.

## Functional API

All paths below are under `/api/v1` except health/OpenAPI. The shared contract lives in `THRIVE/contracts/IMPLEMENTATION_SLICE.md`.

| Area | Routes |
|---|---|
| Onboarding | GET `/consent-policies/current`, GET `/me`, GET/PUT `/me/consents`, POST `/me/consents/withdraw` |
| Instrument | GET `/instruments` |
| Screening | POST `/screening/sessions`, GET `/screening/sessions/{id}`, PUT `/screening/sessions/{id}/answers/{itemCode}`, POST `/screening/sessions/{id}/submit`, GET `/me/screenings` |
| Guide | GET `/guide/resources`, GET `/guide/resources/{id}` |
| Services | GET `/services?level=Counseling|Specialist` |
| Referrals | POST `/referrals`, GET `/me/referrals`, POST `/me/referrals/{id}/cancel` |
| Admin catalog | GET/POST `/admin/services`, PUT `/admin/services/{id}`, GET/POST `/admin/resources`, PUT `/admin/resources/{id}` |
| Admin operations | GET `/admin/referrals`, PUT `/admin/referrals/{id}/status`, GET `/admin/reports/aggregate` |

Errors use ProblemDetails:400 validation,401 missing/invalid identity,403 role/current-consent denial,404 missing or out-of-scope resource,409 conflict/invalid transition. No token or response body is logged by application code.

### Screening and development data

Only `DEMO-CHECK` is available to explicitly enabled development identities. Its three custom questions concern product usability, not mental health. Its technical sum is displayed as `state=Demo`, with no diagnosis, clinical risk level or psychological color band. No HADS/PSS item wording or invented clinical threshold is included.

Answers validate item/options and session ownership. Incomplete submission fails; serial repeated submission returns the same saved result. Submitted sessions are immutable. Optimistic session revision prevents a late answer loaded before a concurrent submission from changing the completed session. A conflict requires refresh/retry. UTC timestamps are normalized to microsecond precision so first responses match PostgreSQL reloads.

Demo catalog data is seeded lazily only for development identities, scoped to their synthetic university. It contains product-navigation guides and simulated services with no fictional telephone numbers or credentials. All entries are labeled `isDemo`; production does not automatically seed or expose them. Resource source/version/review absence are explicit. Published guides can be downloaded by clients as public-content snapshots; no student answers or tokens belong in that cache.

Service verification cannot be granted by a checkbox without institutional reviewer evidence. `verified=true` is rejected; synthetic entries cannot become operational verified services. Live verification/import is a separate institution-governed configuration path. Draft resources and inactive/unverified live services stay out of the student directory.

### Referrals

Minimum-information sharing consent is required before creation. An open referral to the same service is protected against duplication by validation and a database partial unique index. A request is not a confirmed appointment and never implies completion.

Administrative transitions: Requested -> Received or Declined; Received -> Scheduled or Declined; Scheduled -> Completed or Declined. Students may cancel their own Requested/Received/Scheduled referral. Terminal statuses are immutable and repeating the same status is idempotent. Each transition appends an actor/timestamp status event atomically; optimistic concurrency guards competing updates. No external email, SMS, emergency or calendar action is sent by this MVP.

## Verification and remaining release requirements

The backend suite currently has47 passing tests. SQLite integration tests cover actual synthetic JWTs, consent separation/withdrawal, role and university isolation, daily feeling ownership/validation/removal, activity summaries, screening audit, screening validation/resumption/idempotency, stale edits, demo disclosure, draft visibility, referral transitions, and small-cell suppression. SQLite does not reproduce every PostgreSQL behavior; the root development verification runner separately exercises the connected PostgreSQL implementation.

Production SSO and claim mapping, approved privacy/consent text, licensed clinical instruments, institutional reviewer metadata, operational referral/emergency contacts, release hosting, production key management, retention/erasure processes and external delivery systems require institution-specific setup. The implemented application is a connected development MVP and does not claim those external dependencies are complete.

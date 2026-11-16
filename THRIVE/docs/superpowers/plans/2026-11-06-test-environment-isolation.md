# THRIVE Test Environment Isolation Implementation Plan

> **For agentic workers:** Execute these tasks in this session using the user's authorization to modify this test copy. No design changes, domain remodeling, or original-project writes are authorized.

**Goal:** Make this copy independently identifiable and runnable without writing to original resources.

**Architecture:** Keep Flutter, Angular, ASP.NET Core and EF migrations intact. Separate application identifiers, origins, PostgreSQL cluster/credentials, process records and build workspaces; reject unsafe connection settings before migrations or integration writes.

**Tech Stack:** Flutter 3.47.9, Angular 22, .NET 10, PostgreSQL 17, PowerShell.

**Spec:** User request “THRIVE Test — Environment Isolation & Safety Check”, 2026-11-06.

## Global Constraints

- Modify files only inside this workspace; original source/database/processes are read-only.
- No original migrations, data copying, production credentials, or destructive shared-resource commands.
- Test identity: THRIVE Test; Android `edu.thrive.thrive_student.test`; iOS `edu.thrive.thriveStudent.test`.
- Test ports: API 5280; student web 5400; admin 4300; PostgreSQL 55432.
- Test database/user: `thrive_test` / `thrive_test_local`; new random password.
- Keep app business behavior and design unchanged.

## Review Focus

- Copied process records must never allow stopping original processes.
- Inherited environment/connection overrides must fail before shared database writes.
- Existing PostgreSQL data directories/volumes require ownership proof before reuse.
- Flutter junctions and Android mirrors must never resolve to original source.
- Integration checks must validate a live test-backend identity before any mutation.

### Task 1: Establish evidence and regression checks

- [x] Identify frameworks, original identifiers, default connections, shared paths and active ports without exposing secrets.
- [x] Fingerprint original and copied source/configuration for end-of-task comparison.
- [x] Add focused isolation checks; demonstrate their failure on copied configuration before editing it.

### Task 2: Separate application and runtime identity

Files: Android Gradle/manifest; iOS plist/pbxproj; Flutter app/main/cache; web manifest/index; Angular index/proxy/serve configuration; backend launch/CORS/authentication configuration.

- [x] Change installed/display identifiers and cache key; verify no registered external deep links or shared app groups remain.
- [x] Assign test ports and synthetic JWT issuer/audience; leave live identity providers unconfigured.
- [x] Add backend connection validation and read-only live database identity evidence.

### Task 3: Own test resources and safe lifecycle scripts

Files: `scripts/{initialize-local,start-database,start-backend,start-project,stop-project,start-student,start-admin,build-android-debug,verify-development,export-openapi}`; `scripts/lib/{LocalEnvironment,FlutterEnvironment}`; `infrastructure/local/{compose.yaml,.env.example,.env.local}`.

- [x] Rotate copied local credentials; preserve no original credential in the active test environment file.
- [x] Create a new PostgreSQL cluster inside `.local/thrive-test`, with a matching owner record; verify actual server directory/database/role/port before migrations.
- [x] Use instance/root-scoped process records and project-local Flutter/build working directories.
- [x] Reject occupied ports and unsafe lifecycle targets without stopping other applications.

### Task 4: Verify and report

- [x] Run focused isolation checks and backend tests, then migrate only the verified new database and exercise synthetic API workflows.
- [x] Run appropriate Angular and Flutter checks; build an APK and inspect its effective package/label if tooling permits.
- [x] Check emulator availability; perform side-by-side verification only if available.
- [x] Compare original fingerprints and document changed files, actual checks, unresolved limitations and simultaneous run commands in `docs/TEST_ISOLATION.ar.md`.

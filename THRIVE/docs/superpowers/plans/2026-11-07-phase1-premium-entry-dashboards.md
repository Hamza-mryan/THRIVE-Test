# THRIVE Test Phase 1 Implementation Plan

> **For agentic workers:** Execute task-by-task in this authorized session, with the available independent review agent. The superpowers execution subskills named by the generic writing-plans template are not installed; do not claim to run them or install them. Native execution is authorized by the user's Phase 1 prompt.

**Goal:** Audit the actual product and deliver accessible, coherent student-home and university-overview screens while preserving every existing journey and isolation safeguard.

**Architecture:** Retain ChangeNotifier/repositories in Flutter, standalone components/signals/RequestState in Angular, and the existing layered .NET backend. Improve presentation at existing interfaces; move dashboard-specific presentation into its feature and share only real cross-screen tokens/icons. No schema or transport changes.

**Tech Stack:** Flutter 3.47.9 / Dart 3.13.7; Angular 22.2; .NET 10; PostgreSQL 17.

**Spec:** User's “THRIVE TEST — ULTIMATE MASTER DEVELOPMENT PROMPT, PHASE 1”, submitted 2026-11-07; local attachment reviewed in full.

## Global Constraints

- Only this Desktop THRIVE Test tree is writable. Original source and database are protected; no restoration exception from the previous task carries into this task.
- Keep Android edu.thrive.thrive_student.test, iOS edu.thrive.thriveStudent.test, DB thrive_test:55432, API5280, student5400, admin4300.
- No migrations, production secrets/data, new skills, dependencies, framework migrations, fabricated content or clinical claims.
- Preserve routing, separate service/research/sharing consent, server-confirmed persistence, safety access, localization, privacy suppression and all test protections.
- First implementation slice: student home/support pathways and administration overview/shared chrome. Other screens receive audit coverage and regression checks, not wholesale redesign.
- Skills: ui-ux-pro-max, frontend-design, writing-plans, codebase-design, domain-modeling, systematic-debugging when needed, requesting-code-review, verification-before-completion; supported CUA for visual checks.

## Review Focus

- 320/375px, landscape and 200% text must retain controls and scrolling; test layouts in both languages.
- A support tile must preserve its path identifier, accessible name, tap action and keyboard activation.
- null health aggregates must remain suppressed; a genuine zero must remain zero.
- Pending/failing refresh must not create overlapping requests or announce stale data as a successful update.
- Every tool invocation must validate generated output ownership before Flutter can clean previous outputs; compare original fingerprints after builds.

### Task 1: Baseline, audits and design contract

Files: docs/phase1/2026-11-07-audit.ar.md; design-system/thrive-test/MASTER.md; design-system/thrive-test/pages/{student-home,admin-dashboard}.md; GLOSSARY.md; local phase1 evidence.

- [x] Verify the existing owned cluster and runtime identifiers before starting only the test services without migrations.
- [x] Snapshot test source/assets and original fingerprints; inspect scripts and reparse points.
- [x] Read actual skills and run their local research scripts. Reject off-topic generated systems; use verified style/typography/UX results and primary accessibility references.
- [x] Inventory the real screens and inspect feature/presentation boundaries; render representative workflows, both languages and responsive sizes. Label source-only and unrendered coverage explicitly in the audit.
- [x] Record prioritized UI/architecture findings, chosen tokens and actual domain terminology.

### Task 2: Student home and native presentation

Modify: apps/student-mobile/lib/features/home/home_screen.dart; lib/design_system/thrive_theme.dart; optional shared presentation adjustments only where audited. Test: test/home_presentation_test.dart.

Interface: preserve HomeScreen(onPath: ValueChanged<String>?, onHistory: VoidCallback?, activity: ActivityRepository?). Keep check/guide/connect/plus routing and HomeActivityCard persistence unchanged.

- [x] Add failing tests for normal-text contrast >=4.5, path/history actions, accessible tile roles, Arabic/English, narrow and enlarged-text layouts.
- [x] Introduce explicit spacing/path-color tokens, improve hero action clarity and readable adaptive support tiles; keep demo disclosure and urgent help.
- [x] Verify targeted tests, then Flutter analysis and the full suite through Get-ThriveFlutterTooling.

### Task 3: University overview and shared chrome

Modify: src/app/features/dashboard/dashboard.page.ts; create dashboard.page.html/.scss/.spec.ts; src/styles.scss; src/app/app.{ts,html,scss}; src/app/core/i18n/copy.ts. Create a small decorative SVG icon module if used by both shell and overview. Reuse the bundled licensed Noto Sans Arabic font locally.

Interface: retain DashboardPage, route /dashboard, AdminApi.report(): Promise<AggregateReport>, RequestState.run(), authorization and existing DTO shape.

- [x] Add meaningful tests for null suppression versus numeric zero, refresh/pending/retry behavior and localized navigation/labels.
- [x] Separate operational directory counts from privacy-protected aggregates; make links and refresh explicit, with native keyboard controls.
- [x] Scope dashboard presentation to the feature, align typography/tokens, replace ambiguous structural glyphs with decorative vector icons, and verify compact navigation.
- [x] Run Angular tests, production build and formatting; visually check all affected shared-chrome pages.

### Task 4: Review and final evidence

- [x] Obtain read-only independent review with changed files/diff and actual checks; correct important findings.
- [x] Build Android x86_64 and Web through guarded tooling; inspect effective identity and the modified native screen on the owned emulator.
- [x] Re-run appropriate backend and connected synthetic workflow checks; verify both frontend identities and test database.
- [x] Compare original source hashes and isolation checks after generation/building.
- [x] Deliver a report with exact files, research used/rejected, audit coverage, implementation, actual test counts, screenshots, review, limitations and next slice. Distinguish COMPLETED / PARTIALLY COMPLETED / BLOCKED / NOT STARTED.

## Completion record — 2026-11-07

This first implementation slice is COMPLETED. Overall Phase 1 remains PARTIALLY COMPLETED; the plan does not claim whole-product redesign or complete per-screen accessibility coverage.

- Final checks: Flutter49/49 and analysis clean; Angular16/16, format and production build pass; Backend47/47; static isolation7/7; generated-output isolation2/2; seven connected synthetic verification groups pass.
- Android x86_64 debug build/install and test identity verified; modified native Home inspected. Flutter Web build passed. iOS, Docker, physical devices and actual screen readers remain untested.
- Four Arabic/English success/error rendered-DOM presentation fixtures at320px/root32px have no measured internal overflow after fixes. This is explicitly distinct from live browser zoom.
- Independent read-only review found reflow defects; corrections and final contrast follow-up approved at source level, with fresh closing Angular checks after the last color edits. No open review findings.
- Original recorded source/assets281/281 unchanged; no backend/schema/migration or isolation-script changes.
- Full coverage, limitations, pending priorities and exact files: docs/PHASE1_REPORT.ar.md, docs/phase1/2026-11-07-audit.ar.md, docs/PHASE1_CHANGED_FILES.md.

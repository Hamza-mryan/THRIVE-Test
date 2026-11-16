# THRIVE Test Frontend V2 Implementation Plan

> Execute natively in the current authorized session, milestone by milestone, with fresh read-only review. Generic superpowers execution subskills are not installed; no installation or claim of using them. The user's explicit command authorizes implementation without a separate planning approval. Only this Test directory is writable, including rollback artifacts; the parent Git index/HEAD is outside scope.

**Goal:** Deliver a coherent student and administration frontend beyond Home, preserving working workflows and verified isolation.

**Architecture:** Keep Flutter repositories/ChangeNotifier/Navigator and Angular standalone signals/RequestState. Shared presentation owns typography, spacing, headings, controls and feedback. Feature-specific layouts stay in their feature. Backend policies, DTOs, auth and storage remain unchanged. Correct Home activity freshness only after a reproducing test.

**Tech Stack:** Existing Flutter3.47.9/Dart3.13.7, Angular22.2.4/TypeScript6.0.3, .NET10/PostgreSQL17. No added dependencies.

**Spec:** User attachment a02b85e8-c246-4c09-a8b0-03b9a4dfd4b2, THRIVE TEST PHASE2, submitted2026-11-07; Phase1 report/audit/design-system/glossary read at their verified locations.

## Global constraints

- Only C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE. Original Documents project is read-only.
- Preserve edu.thrive.thrive_student.test, edu.thrive.thriveStudent.test, thrive_test:55432, API5280, student5400, admin4300. Never run start-project.ps1/migrations for design.
- Guard all Flutter commands with Get-ThriveFlutterTooling; generated files must remain inside the verified Test root/drive.
- Preserve separate service/research/referral-sharing consent, ownership, referral transitions, published-only guidance, optional mood, strict-null suppression, demo disclosures and urgent help.
- Keep Arabic/English and RTL; no real clinical data, fake providers/metrics, unlicensed clinical instruments, external source/code upload or private information in Canva.
- Rollback exists before implementation: .local/thrive-test/phase2-2026-11-07/phase1-rollback.zip plus source-before (306 files), and a fresh original hash baseline (281 files).

## Review focus

- Return from pushed check/service pages must refresh activity without recreating the whole Home scroll position; disposal must not update unmounted state.
- 320px and200% text must retain form controls, long Arabic labels and urgent help; desktop navigation must preserve all five destinations.
- Research refusal never disables service consent submission; referral sharing must remain explicit.
- Sensitive null must remain suppressed and numeric zero preserved; successful UI states wait for server confirmation.
- Resource/service editor extraction must preserve validators, disabled state, field values, save/cancel and immutable verification flags.

## A/B — Direction and design contract

- [x] Verify root, reparse points, live database identity and7 static isolation checks; snapshot rollback.
- [x] Run design-system exploration and three explicit RTL style searches: organic-biophilic, swiss-modernism-2-0, soft-ui-evolution. Reject marketing/conversion composition from generic generator.
- [x] Generate an editable four-page Canva comparison from a generic non-sensitive brief only: DAHaO6VINHA, https://canva.link/oftphx34mgfwgmj. No source/assets/private uploads; no app screenshot claim.
- [x] Record evaluated alternatives and V2 contract in design-system/thrive-test/MASTER.md and docs/phase2/SCREEN_COVERAGE.md.

## C/D — Flutter foundation and working student journeys

Files: lib/design_system/{thrive_theme,thrive_widgets,async_content}.dart; lib/app/{student_shell,feature_scaffold}.dart; every existing features/*/presentation screen plus history_screen.dart, policy_screen.dart and safety_sheet.dart; paired ARB strings where needed. Tests: test/activity_return_test.dart and test/frontend_v2_presentation_test.dart, retaining all existing tests.

Interfaces: deepen existing FeatureIntro(title, body, icon, eyebrow?, accent?, background?) with optional trailing action instead of adding a duplicate heading abstraction; existing SurfaceCard/PageContent/StatusPill/InlineNotice interfaces remain usable. HomeScreen gains optional activityRevision default0; only the activity subtree receives that revision. StudentShell's existing callbacks/path identifiers stay unchanged. Repository interfaces and API transport stay unchanged.

- [x] Add and run a reproducing navigation test with synthetic in-memory API state: change activity while Check is pushed, pop, assert fresh count and repeat-read. Record failure before correction.
- [x] Make a focused return refresh, then rerun the failing scenario including disposal behavior.
- [x] Implement mineral-white/evergreen tokens, legible native type/controls, common page hierarchy, feedback and responsive navigation; preserve platform interaction and help.
- [x] Redesign welcome/consent; history/resume; Check/questions/result; guide/article/breathing; counseling/specialist directory/detail/request; referrals; account/policies/safety. Preserve callbacks, state and existing content meaning. Home receives V2 consistency rather than another isolated redesign.
- [x] Add meaningful reflow/semantics coverage across the actual feature widgets, both languages and enlarged text. Run analysis and full tests via guarded tooling.
- [x] Review rendered student journeys and adjust demonstrable defects only.

## E — Angular complete administration presentation

Files: app shell/styles; features/{services,resources,referrals}/*.page.ts plus extracted .html/.scss; dashboard styles as needed; core/i18n/copy.ts; existing tests and focused presentation regression tests.

Interfaces: retain ServicesPage, ResourcesPage, ReferralsPage, AdminApi methods, all current DTOs, RequestState and validators. Extract feature templates without changing workflow code. Share actual shell/icons/tokens; no universal page schema or new state library.

- [x] Refine navigation/login and overview consistently with V2.
- [x] Implement legible service/resource collections and grouped bilingual editor fields with existing validation, save/cancel and institutional flags preserved.
- [x] Refine referral table, status actions, empty/loading/error feedback and bounded keyboard-accessible narrow scrolling without showing student identities.
- [x] Run Angular tests/format/production build and inspect every page/form in the browser at relevant sizes and languages.

## F/G/H — Verification, critique and review

- [x] Obtain fresh independent read-only review against source-before/diff and real evidence; fix important findings and rerun affected checks.
- [x] Build Android x86_64 and Web through guarded scripts; verify test APK identity before test-only installation, and inspect actual rendered result where control is available.
- [x] Run backend47 tests, connected synthetic workflows and isolation/generated-output fixtures as appropriate. Recheck original hashes after Flutter generation/building.
- [x] Update screen coverage with separate implementation and verification status. Deliver exact changed files, Canva usage/link, tests/builds, screenshots, review and remaining limits. Never infer full visual/accessibility verification from shared styling or tests alone.

## Execution outcome

All implementation steps above were executed for existing views. Final evidence: Flutter118, Angular20, Backend47, isolation7/7, generated-output2/2; guarded Android/Web builds and actual browser/native checks. Three source findings were corrected with regression coverage, plus the confirmed stale-activity issue. Final bilingual editor layout was refined and re-reviewed after screenshots. See docs/PHASE2_REPORT.ar.md, phase2/SCREEN_COVERAGE.md, VERIFICATION.md and REVIEW.md. Live200% browser zoom, real assistive technology, iOS/physical devices and every error-state permutation remain unverified; checked steps do not claim those outcomes.

# THRIVE Test Phase3 — Refinement and QA Implementation Plan

> Execute natively, task by task, in this authorized session, with fresh independent read-only code review. The user explicitly requests implementation now; no additional planning approval. The generic superpowers execution subskills are not installed and will not be claimed or installed. Git index/HEAD are outside the writable Test root; use the existing local rollback/diff workflow.

**Goal:** Audit the27 existing coverage items and improve confirmed usability/reliability defects without restarting the Campus Sanctuary redesign.

**Architecture:** Preserve feature ownership, Flutter repositories/ChangeNotifier/Navigator and Angular signals/RequestState/template forms. UI presentation and transport failure handling may be refined; domain/backend contracts and authoritative validators remain unchanged. Controlled fault previews must be local Test-only tools and clearly distinguished from PostgreSQL-connected journeys.

**Tech Stack:** Existing Flutter/Dart, Angular/TypeScript/RxJS, .NET10 and owned PostgreSQL17. No added dependency.

**Spec:** User attachment84779edf-2318-4972-be8b-c8831f201f63, THRIVE Test Phase3,2026-11-07. Phase2 report/coverage/review/verification/file list and V2 Master are the historical baseline.

## Global constraints

- Only C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE is writable. Original Documents project remains protected.
- Keep Android edu.thrive.thrive_student.test, iOS edu.thrive.thriveStudent.test, database thrive_test/thrive_test_local:55432, API5280, student5400 and administration4300.
- Never run migrations or start-project.ps1 for QA. Every Flutter command uses Get-ThriveFlutterTooling and verified Test outputs.
- Preserve authentication/authorization, memory-only sessions, ownership, service/research/referral-sharing separation, unverified-contact gates, suppression/null semantics, technical demo labels, public-only downloads and persistent urgent help.
- Synthetic data only. Never send external calls/messages/referrals or log tokens/answers/results. No source/private uploads, new skills or packages.
- Before edits: fresh ownership/identity checks passed; Phase2 source hashes match; rollback320 files and original281 hashes recorded under .local/thrive-test/phase3-2026-11-07.

## Review focus

- A hung administration request must eventually release busy state and explain recovery; no automatic write retry.
- Session expiry must preserve authorization while giving a visible route back to sign-in, without displaying server bodies.
- Invalid fields must have understandable feedback without weakening the existing validators or changing save payloads.
- All five student destinations/help and all four administration links remain usable in narrow/landscape/enlarged-text configurations; RTL follows reading order.
- Error/retry/empty/loading states stay distinct and keyboard focus is neither lost nor obscured; public saved content must not carry private session data.

## Task1 — Audit and baseline, P0/P1/P2 classification

**Files:** docs/phase3/{AUDIT,SCREEN_COVERAGE,VERIFICATION,PERFORMANCE}.md; .local/thrive-test/phase3-2026-11-07/{source-before,test-before.json,original-before.json,phase2-rollback.zip,screenshots/}; existing design-system/thrive-test/MASTER.md.

**Interfaces:** Use the Phase2 F01–F20/A01–A07 IDs; record typography/hierarchy/spacing/alignment/color/readability/proportion/navigation/density/accessibility/consistency/refinement for each. Record actual inspected configuration and distinguish DOM/widget/browser/native evidence. Preserve successful design decisions.

- [x] Verify Test path, live database identity,7 static isolation checks and Phase2 source hashes; snapshot320 selected source/assets/docs and281 original hashes.
- [ ] Run focused UI/UX searches for error clarity, focus visibility and narrow navigation; record accepted/rejected guidance.
- [ ] Inspect actual main views, priority states and landscape/tablet/narrow configurations; create prioritized findings from observed evidence.
- [ ] Measure local request durations, bundle/asset sizes and selected browser timings before any performance optimization. Do not infer production performance.

## Task2 — Expanded Flutter rendering and failure evidence

**Files:** modify apps/student-mobile/test/frontend_v2_presentation_test.dart; add test/frontend_quality_test.dart if shared feedback/shell cases need dedicated coverage; modify affected existing presentation files only after a failing case.

**Interfaces:** Existing feature widgets/repositories remain the test seam. Rendering transport is GET-only synthetic MockClient; fake failures use ApiFailure kinds and delayed futures. No domain write is required for layout testing.

- [ ] Extend the existing16-view bilingual matrix with700×320/100%,800×600/150% and320×700/200%, retaining prior cases and reduced-motion flags.
- [ ] Exercise full shell/help navigation in short landscape and delayed/error/retry/unauthorized feedback with semantics and synthetic data.
- [ ] For each confirmed failure, retain red evidence, identify its source cause, implement the smallest presentation correction and rerun the case.
- [ ] Run guarded analyze and the full Flutter suite, then inspect affected actual web/native views. No test-only success may be described as a physical-device result.

## Task3 — Administration reliability and usable feedback

**Files:** apps/university-admin/src/app/core/api/admin-api{,.spec}.ts; app.{ts,html,scss}; core/i18n/copy.ts; shared/request-state/request-feedback.ts; features/{services,resources}/*.page.html and focused tests only where evidence requires them.

**Interfaces:** Keep AdminApi public methods/DTOs and RequestState.run unchanged. A confirmed hung-request fix should apply a12,000ms bound to both the isolation handshake and API response, map failure without server payloads, release busy and never retry writes automatically. Use existing RxJS. Keep existing form validators and disabled/pending behavior; any feedback module must consume their errors rather than duplicate validation rules. Record an exact focused implementation amendment after the rendered form audit if required.

- [ ] Reproduce pending request beyond12s and expired-session behavior using HttpTestingController/fake timers before implementing corrections.
- [ ] Add bounded failure/recovery behavior only for confirmed defects; add bilingual copy and regression assertions.
- [ ] Inspect invalid required/email/slug fields in real forms; retain values and focus; improve only missing or unclear feedback.
- [ ] Measure narrow navigation composition before changing it; if excessive chrome is confirmed, refine the existing responsive grid without hiding destinations.
- [ ] Run formatting, tests and production build; verify actual affected forms/navigation/errors at desktop/laptop/tablet/mobile and both languages.

## Task4 — Actual journeys, edge cases and accessibility

**Task3 amendment from confirmed evidence:** Add shared/form-feedback/field-feedback.ts, a presenter with errors:ValidationErrors|null and show:boolean|null inputs. The two explicit editor templates export NgModel refs and associate visible error messages using stable IDs/aria-invalid/aria-describedby; feedback sits outside the native label in a min-width:0 field wrapper. It maps existing required/email/pattern/maxlength errors to paired copy, reading requiredLength rather than duplicating limits. No field schema or new validator. AdminApi uses a private session version so a late401 from a previous sign-in cannot clear a newer memory session. Source/API tests reproduced nine failures before these fixes. Responsive navigation's measured baseline is224px high, content top457px at320×700; refine to two wrapping columns with all four links retained. Specialized Angular navigation search returned0 twice; this choice follows measured UI and general layout rules, not a database match.

**Files:** local QA preview/fault tools and evidence under .local/thrive-test/phase3-2026-11-07; scripts/verify-development.mjs remains unchanged.

**Interfaces:** Real workflows target verified API5280 and owned PostgreSQL. A controlled administration preview may serve the actual production build and proxy only to localhost:5280, with fault injection restricted to synthetic GET responses, under a distinct loopback port. It is not a replacement backend or production feature. Browser/Android interaction uses the supported computer-use surface.

- [ ] Verify development sign-in, separate consent, Home/Check completion/pause/resume/result/history, Guide/article/public save, Connect/Plus/detail/referral/cancel, account/policies/help with synthetic identities.
- [ ] Verify administration overview/services/resources/edit/cancel/validation/referral table and authorization boundaries.
- [ ] Observe unavailable/timeout/401/empty/slow/retry states with safe controlled responses where necessary. Clearly label simulated transport failures and untested global network outage.
- [ ] Check keyboard focus, native semantics, labels, error announcements, touch target geometry, contrast, RTL, reduced motion and text scaling. Probe TalkBack availability; do not install/claim unavailable tooling.

## Task5 — Final review and evidence gate

**Files:** docs/PHASE3_REPORT.ar.md, docs/PHASE3_CHANGED_FILES.md, docs/phase3/*, design-system/thrive-test/MASTER.md and START_HERE only if needed.

- [ ] Obtain fresh independent read-only reviews of immutable scoped source diff; fix confirmed important findings and rerun affected checks.
- [ ] Run Flutter analysis/full suite, Angular format/tests/production build, relevant Backend tests and isolation/generated-output checks. Build updated Android/Web if Flutter source changes.
- [ ] Reverify owned live database, runtime destinations, protected original281 hashes and exact changed files. Preserve rollback and final source hashes.
- [ ] Deliver actual screenshots, tested configurations/journeys/performance measurements, pass/fail evidence and completed/partial/blocked/not-tested distinctions. No claim of release, clinical or accessibility certification.

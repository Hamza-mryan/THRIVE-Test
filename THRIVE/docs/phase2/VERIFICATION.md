# Phase2 — execution evidence

2026-11-07, Asia/Amman. Counts below are fresh Phase2 executions, not carried over from Phase1. No backend or schema source changed. Evidence directory: `.local/thrive-test/phase2-2026-11-07`.

| Check | Observed result | Evidence file |
|---|---|---|
| Flutter analysis | Exit0, no issues | flutter-analyze-final.log |
| Flutter full suite |118 passed, no skipped/disabled tests introduced | flutter-tests-final.log |
| Presentation matrix within that suite |64 cases:16 actual views×AR/EN×320/100% and375/200% | frontend_v2_presentation_test.dart and full-suite log |
| Return/resize/short-rail regression cases |5 passed; failing-before-fix evidence retained | activity-red.log, rail-review-red.log, rail-short-red.log, rail-review-green.log |
| Angular formatting | All matched files use Prettier style | angular-final-format-check.log |
| Angular full suite |20 passed,4 files | angular-final-test.log |
| Angular production build after final editor CSS | Exit0 | angular-final-build.log |
| Backend full suite |47 passed,0 failed,0 skipped; SQLite in memory | backend-tests-final.log |
| Static isolation checks |7/7 | isolation-final.log |
| Copied-output protection |2 cases pass; outside sentinel preserved, foreign outputs rejected | generated-isolation-final.log |
| Live database ownership | Actual thrive_test/thrive_test_local/serverPort55432, owned data_directory | live-database-final.json and Assert-ThriveTestDatabase |
| Connected synthetic workflows | All verification groups pass | connected-workflows-final.log |
| Protected original comparison |281 selected source/assets unchanged,0 missing | original-final-comparison.json |
| Guarded Android debug x86_64 build | Exit0, APK produced | android-build.log |
| Guarded Flutter Web build | Exit0 | web-build.log |
| APK inspection and installation | THRIVE Test / edu.thrive.thrive_student.test, install Success | android-identity-final.txt plus executed install output |
| Application coexistence | Installed original UID10235 and Test UID10236 in owned THRIVE_Test AVD | android-identity-final.txt, screenshots/android-two-apps.jpg |
| Live browser console during journeys |0 captured error-level messages for student and both admin tabs at collection time | browser-console-errors.json |
| Safe runtime availability | API readiness5280, student5400 and administration4300 returned HTTP200 | runtime-final.json |

## Actual interaction and visual review

Student browser: wide1200×900/1280×720, narrow375×812; Arabic and English across the journeys, not every possible combination. A synthetic usability session was saved, paused, resumed from History at its next question, submitted, and shown as a technical demo result. Home refreshed from0 to1 in-progress without reload after returning. A synthetic referral required explicit sharing, appeared in administration, and was cancelled through the student confirmation dialog. Synthetic service withdrawal led to consent; service-only reconsent restored access with research unchecked. An optional synthetic daily entry produced a single real chart point and was then removed. A public resource was saved, retained after sign-out and read from the saved library without authentication. No forced network outage or external call was performed.

Administration browser: AR/EN desktop1440×1000, narrow375×812 and320×700. Service/resource collections and create/edit forms loaded actual synthetic records; heading focus, cancel focus, input language/direction and disabled verification were observed. Inputs used for layout checks were cancelled, not submitted. The referral table used a named keyboard-focusable318px region containing a610px table at375px, without whole-page overflow. Final editor refinement was inspected again: two488px columns at1440; one278px column at375, document scrollWidth360≤viewport375.

Owned Android AVD: actual welcome, development sign-in, Home, Guide, urgent-help sheet and native Back. Original and Test icons were simultaneously visible. Only Test was reinstalled in Phase2. The original application was not rebuilt, reinstalled or freshly launched this phase. Android screenshots are of the actual running debug build, not mockups. ADB uses5047; emulator5580 and authenticated local gRPC8580. No production services or original AVD data were used.

Normal viewport screenshots are in `screenshots/`. Files containing `final` supersede earlier captures of the same screen. In particular, earlier desktop editor images show the inspected three-column version; `admin-service-editor-final-ar-desktop.jpg` and `admin-resource-editor-final-en-desktop.jpg` show the final two-column source. Screenshot filenames are an index, not a claim that every pixel below the fold or every state was reviewed.

## Reproduction commands and boundaries

Every Flutter invocation used the verified Test tooling/drive, including generation, analysis, tests and builds:

```powershell
. .\scripts\lib\FlutterEnvironment.ps1
$testRoot = (Get-Location).Path
$tooling = Get-ThriveFlutterTooling $testRoot
Push-Location $tooling.Workspace
try {
    & $tooling.Executable analyze --no-pub
    & $tooling.Executable test --no-pub --reporter expanded
} finally { Pop-Location }
```

Native build: `scripts/build-android-debug.ps1 -EnableDevelopmentIdentity -TargetPlatform android-x64`. Web build used the same guarded tooling with `build web --no-web-resources-cdn --dart-define=ENABLE_DEVELOPMENT_IDENTITY=true --dart-define=API_BASE_URL=http://localhost:5280`.

Administration: `npm run format:check`, `npm test`, `npm run build` from apps/university-admin, with npm cache inside Test. Backend: the owned generated-workspace guard, local .NET10, Test CLI/cache directories, and `dotnet test tests/Thrive.Tests/Thrive.Tests.csproj --no-restore`. Database verification preceded the synthetic connected writer. No migration switch or start-project.ps1 was used.

## Limits

No fresh iOS/Xcode build, physical device/ARM64/release validation, installed PWA, Docker runtime, TalkBack/VoiceOver, formal WCAG audit, browser live200% zoom, all error/session-expiry permutations or load/performance measurement. Flutter200% is actual widget-render evidence, not an assistive-technology claim. Backend tests use SQLite; connected verification separately exercises owned PostgreSQL. Current Test runtime was reverified; simultaneous original runtime execution is historical Phase0 evidence, not rerun in Phase2. Original hash comparison covers281 recorded source/assets, not every cache file or external resource.

Flutter Web reported the existing missing CupertinoIcons-family warning; Android tooling reported SDK XML-version compatibility warnings. Both builds completed. No fake clinical instrument/contact was enabled to make a screen appear complete.

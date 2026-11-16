# THRIVE Student Frontend

هذه النسخة هي **THRIVE Test**. إعدادات التشغيل الحالية في [تقرير العزل](../../docs/TEST_ISOLATION.ar.md).

Flutter student app foundation, Arabic first with English. Framework pinned to **Flutter 3.47.9 / Dart 3.13.7** in `.flutter-version`; dependency versions resolved in `pubspec.lock`.

## Implemented

- Responsive welcome, independent service/research consent, and a connected five-tab student workspace: home, history, guide, referrals and account.
- Global urgent-help entry point before and after sign-in; the help sheet works without an API call and contains no invented contacts.
- Bundled Noto Sans Arabic regular/bold fonts with OFL license, shared theme/tokens and reusable widgets.
- SDK `ChangeNotifier` controller with injected onboarding repository; centralized typed HTTP failure mapping and 12-second transport timeouts.
- Actual API requests for an explicitly enabled development identity and server-side consent save/restore. Research refusal permits service use.
- Resumable server-backed demonstration questionnaire, server-produced technical result, and session history. Questions test product usability; they do not constitute a psychological instrument.
- Published guide search/categories/details and explicit offline downloads. Public guide text is the only persistent local content. Saved guides can be read before sign-in, including after a restart without network access.
- Counseling/specialist service directories, explicit sharing consent, referral requests/status and cancellation. Simulated services are labeled and never contact real providers.
- Account research-consent updates and service withdrawal. Withdrawal immediately gates the functional workspace and returns to consent.
- Controller/transport/widget tests cover consent separation, failed saves, resume behavior, server scores, public-only cache, withdrawal, safety, localization and small-screen large text.
- Reference PDF coverage additions: privacy/terms screens before sign-in and in Account; current activity counts and optional daily feeling save/change/remove with seven-day self-report history; direct support links from guides/results; explicit unverified contact status on Safety. The feeling diary is not a clinical instrument or risk signal.

The real university identity provider is pending. Production/default builds keep development sign-in disabled. HADS/PSS and other clinical tools remain disabled until licensing/content and institution approval are supplied. The development questionnaire and simulated directories are clearly labeled; they do not provide real clinical screening or live appointments.

## Local setup and preview

Run all commands from the **THRIVE Test root**. Initialize only this copy, then use the guarded launchers:

```powershell
./scripts/initialize-local.ps1
./scripts/start-project.ps1 -EnableDevelopmentIdentity
```

The student preview is http://localhost:5400 and the isolated API is http://localhost:5280. SDK tools may be shared, but copied build metadata is quarantined inside this project before Flutter runs. Never reuse the original global Flutter junction or Android mirror.

For checks, obtain the owned workspace first:

```powershell
. ./scripts/lib/FlutterEnvironment.ps1
$tooling = Get-ThriveFlutterTooling (Get-Location).Path
Push-Location $tooling.Workspace
try {
    & $tooling.Executable pub get --offline
    & $tooling.Executable analyze
    & $tooling.Executable test
} finally { Pop-Location }
```

The helper validates an unused drive mapping to this project only (currently T:). Source and all mutable generated state remain inside this project. Existing cached Flutter output paths outside it are refused before tool execution.

Build for an x86_64 emulator:

```powershell
./scripts/build-android-debug.ps1 -EnableDevelopmentIdentity -TargetPlatform android-x64
```

Output: output/android/THRIVE-Test-development-x64.apk. Effective Android ID: edu.thrive.thrive_student.test. The default API address is http://10.0.2.2:5280. The build script rejects original/remote API addresses. Both clients verify the actual test backend/database identity before obtaining a synthetic session.

For an explicitly selected physical device, use ADB reversal:

```powershell
adb -s SERIAL reverse tcp:5280 tcp:5280
./scripts/build-android-debug.ps1 -EnableDevelopmentIdentity -ApiBaseUrl http://127.0.0.1:5280
```

The x86_64 APK was built and launched alongside the original reference APK in a new empty test AVD. Physical-device and ARM64 runtime checks were not performed. iOS identifiers were separated; native iOS compilation requires macOS/Xcode. Debug signing and local HTTP are development-only settings.

For a web artifact, obtain the guarded workspace as above, then run the build there:

```powershell
Push-Location $tooling.Workspace
try { & $tooling.Executable build web --no-web-resources-cdn } finally { Pop-Location }
```

The web preview uses a separate origin, manifest identity and public-guide cache key. Flutter manages direction inside its widgets; keep HTML host direction unset. See [the isolation report](../../docs/TEST_ISOLATION.ar.md) for the actual verification results and incident/recovery record.

## Architecture and privacy

```text
lib/
  app/                    composition, global shell and five-tab workspace
  core/network/           HTTP/session boundary and typed failures
  design_system/          theme and shared UI
  features/onboarding/    controller, repository, welcome and consent
  features/home/          four module entry points
  features/screening/     repository, controller, questionnaire and result
  features/history/       saved/completed server sessions
  features/guide/         published content, details and public-only offline cache
  features/referrals/     directories, sharing consent, request/status/cancel
  features/account/       profile and consent management
  features/safety/        locally available help sheet
  l10n/                   ARB resources and generated translations
```

Tokens, questionnaire answers and results are kept **in memory or on the server**, never in localStorage/shared preferences. Refreshing/restarting requires a new development session; the server then restores consent and saved sessions for the same synthetic identity. Persistent production sign-in is not implemented. Shared preferences holds only explicitly downloaded published public guide text under `thrive-test.public-guides.v1`. No HTTP bodies/tokens are logged.

Translate text in `lib/l10n/app_ar.arb` and `app_en.arb`; `flutter pub get` regenerates localization. Do not edit generated localization classes manually. Widget screens call controller actions, not HTTP. Domain screening decisions remain in the backend.

References: [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide), [Flutter localization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization), [Noto fonts and license](https://github.com/notofonts/noto-fonts).

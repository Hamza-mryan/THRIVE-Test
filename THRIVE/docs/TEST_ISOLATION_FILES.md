# ملفات عزل THRIVE Test

كل المسارات أدناه داخل نسخة الاختبار الحالية؛ المسارات من جذر THRIVE ما لم يذكر غير ذلك.

## ملفات معدّلة

- apps/student-mobile/android/app/build.gradle.kts
- apps/student-mobile/android/app/src/main/AndroidManifest.xml
- apps/student-mobile/android/gradle.properties
- apps/student-mobile/ios/Runner.xcodeproj/project.pbxproj
- apps/student-mobile/ios/Runner/Info.plist
- apps/student-mobile/lib/app/thrive_app.dart
- apps/student-mobile/lib/design_system/thrive_widgets.dart
- apps/student-mobile/lib/features/guide/data/guide_repository.dart
- apps/student-mobile/lib/features/onboarding/data/onboarding_repository.dart
- apps/student-mobile/lib/main.dart
- apps/student-mobile/README.md
- apps/student-mobile/web/index.html
- apps/student-mobile/web/manifest.json
- apps/university-admin/angular.json
- apps/university-admin/proxy.conf.json
- apps/university-admin/README.md
- apps/university-admin/src/app/app.html
- apps/university-admin/src/app/core/api/admin-api.spec.ts
- apps/university-admin/src/app/core/api/admin-api.ts
- apps/university-admin/src/index.html
- docs/RUN_LOCAL.ar.md
- docs/START_HERE.ar.md
- infrastructure/local/.env.example
- infrastructure/local/compose.yaml
- infrastructure/local/README.md
- README.md
- scripts/build-android-debug.ps1
- scripts/export-openapi.ps1
- scripts/initialize-local.ps1
- scripts/lib/FlutterEnvironment.ps1
- scripts/lib/LocalEnvironment.ps1
- scripts/start-admin.ps1
- scripts/start-backend.ps1
- scripts/start-database.ps1
- scripts/start-project.ps1
- scripts/start-student.ps1
- scripts/stop-project.ps1
- scripts/verify-development.mjs
- services/backend/README.md
- services/backend/src/Thrive.Api/appsettings.json
- services/backend/src/Thrive.Api/Identity/DevelopmentTokenIssuer.cs
- services/backend/src/Thrive.Api/Program.cs
- services/backend/src/Thrive.Api/Properties/launchSettings.json
- infrastructure/local/.env.local — إعداد محلي متجاهل في Git؛ استبدلت أسرار النسخة المنسوخة دون إدراج قيمها.
- ../.github/workflows/thrive-ci.yml — منافذ وأسماء قاعدة CI موافقة لحارس Test؛ لم يُشغّل GitHub Actions في هذه المهمة.

## ملفات مضافة

- apps/student-mobile/test/environment_isolation_test.dart
- docs/superpowers/plans/2026-11-06-test-environment-isolation.md
- docs/TEST_ISOLATION.ar.md
- scripts/lib/GeneratedWorkspace.ps1
- scripts/stop-database.ps1
- scripts/verify-generated-isolation.ps1
- scripts/verify-isolation.mjs
- services/backend/src/Thrive.Api/TestEnvironment.cs
- services/backend/tests/Thrive.Tests/EnvironmentIsolationTests.cs
- docs/TEST_ISOLATION_FILES.md

## مخرجات محلية متجاهلة في Git

- .local/thrive-test/: قاعدة الاختبار وسجلات الملكية والعمليات والمحاكي وGradle وسجلات التحقق واللقطات وحزمة الاستعادة.
- output/android/THRIVE-Test-development-x64.apk: ملف Android المختبر.
- نُقلت حالة البناء المنسوخة إلى quarantine داخل .local/thrive-test قبل إعادة إنشائها.

## استثناء وافق عليه المستخدم في الأصل

أُعيدت الملفات الثلاثة المفقودة التالية فقط ببيانات مطابقة لبصماتها الأصلية، بعد موافقة المستخدم الصريحة:

- apps/student-mobile/lib/l10n/app_localizations.dart
- apps/student-mobile/lib/l10n/app_localizations_ar.dart
- apps/student-mobile/lib/l10n/app_localizations_en.dart

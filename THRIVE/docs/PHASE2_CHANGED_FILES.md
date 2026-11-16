# Phase2 — الملفات الدقيقة

2026-11-07. مقارنة مع306 ملفات مختارة قبل Phase2 في source-before/test-before.json. تشمل القائمة تغييرات المصدر والاختبارات والتوثيق في هذه المرحلة فقط؛ تغييرات العزل وPhase1 السابقة ليست تغييرات جديدة هنا.

## المصدر والاختبارات

35 ملفًا:24 في Flutter و11 في Angular. ملفات الترجمة الثلاثة مولّدة بالأداة المحروسة. لم يتغير Backend أو عقود API أو repositories/controllers أو إعدادات الهوية/قاعدة البيانات أو حزم الاعتماد أو سكربتات التشغيل.

| الملف | الحالة | المسؤولية |
|---|---|---|
| [apps/student-mobile/lib/app/feature_scaffold.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/app/feature_scaffold.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/app/student_shell.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/app/student_shell.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/design_system/feature_intro.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/design_system/feature_intro.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/design_system/thrive_theme.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/design_system/thrive_theme.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/design_system/thrive_widgets.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/design_system/thrive_widgets.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/account/presentation/account_screen.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/account/presentation/account_screen.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/guide/presentation/breathing_practice.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/guide/presentation/breathing_practice.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/guide/presentation/guide_screen.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/guide/presentation/guide_screen.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/guide/presentation/guide_topic.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/guide/presentation/guide_topic.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/history/history_screen.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/history/history_screen.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/home/home_screen.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/home/home_screen.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/onboarding/presentation/consent_screen.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/onboarding/presentation/consent_screen.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/onboarding/presentation/welcome_screen.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/onboarding/presentation/welcome_screen.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/policies/policy_screen.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/policies/policy_screen.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/referrals/presentation/referral_screens.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/referrals/presentation/referral_screens.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/safety/safety_sheet.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/safety/safety_sheet.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/features/screening/presentation/screening_screens.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/features/screening/presentation/screening_screens.dart>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/l10n/app_ar.arb](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/l10n/app_ar.arb>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/l10n/app_en.arb](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/l10n/app_en.arb>) | معدّل | واجهة Flutter |
| [apps/student-mobile/lib/l10n/app_localizations.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/l10n/app_localizations.dart>) | معدّل | ترجمة مولّدة بالأداة؛ لا تحرير يدوي |
| [apps/student-mobile/lib/l10n/app_localizations_ar.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/l10n/app_localizations_ar.dart>) | معدّل | ترجمة مولّدة بالأداة؛ لا تحرير يدوي |
| [apps/student-mobile/lib/l10n/app_localizations_en.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/lib/l10n/app_localizations_en.dart>) | معدّل | ترجمة مولّدة بالأداة؛ لا تحرير يدوي |
| [apps/student-mobile/test/activity_return_test.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/test/activity_return_test.dart>) | جديد | اختبار سلوك/عرض |
| [apps/student-mobile/test/frontend_v2_presentation_test.dart](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/student-mobile/test/frontend_v2_presentation_test.dart>) | جديد | اختبار سلوك/عرض |
| [apps/university-admin/src/app/app.html](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/app.html>) | معدّل | واجهة Angular |
| [apps/university-admin/src/app/core/i18n/copy.ts](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/core/i18n/copy.ts>) | معدّل | واجهة Angular |
| [apps/university-admin/src/app/features/editor-presentation.spec.ts](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/editor-presentation.spec.ts>) | جديد | اختبار سلوك/عرض |
| [apps/university-admin/src/app/features/referrals/referrals.page.html](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/referrals/referrals.page.html>) | جديد | واجهة Angular |
| [apps/university-admin/src/app/features/referrals/referrals.page.scss](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/referrals/referrals.page.scss>) | جديد | واجهة Angular |
| [apps/university-admin/src/app/features/referrals/referrals.page.ts](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/referrals/referrals.page.ts>) | معدّل | واجهة Angular |
| [apps/university-admin/src/app/features/resources/resources.page.html](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/resources/resources.page.html>) | جديد | واجهة Angular |
| [apps/university-admin/src/app/features/resources/resources.page.ts](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/resources/resources.page.ts>) | معدّل | واجهة Angular |
| [apps/university-admin/src/app/features/services/services.page.html](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/services/services.page.html>) | جديد | واجهة Angular |
| [apps/university-admin/src/app/features/services/services.page.ts](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/app/features/services/services.page.ts>) | معدّل | واجهة Angular |
| [apps/university-admin/src/styles.scss](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/apps/university-admin/src/styles.scss>) | معدّل | واجهة Angular |

## التوثيق ونظام التصميم

- [design-system/thrive-test/MASTER.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/design-system/thrive-test/MASTER.md>) — معدّل
- [design-system/thrive-test/PHASE1_BASELINE.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/design-system/thrive-test/PHASE1_BASELINE.md>) — جديد
- [docs/PHASE2_CHANGED_FILES.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/docs/PHASE2_CHANGED_FILES.md>) — جديد
- [docs/PHASE2_REPORT.ar.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/docs/PHASE2_REPORT.ar.md>) — جديد
- [docs/START_HERE.ar.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/docs/START_HERE.ar.md>) — معدّل
- [docs/phase2/REVIEW.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/docs/phase2/REVIEW.md>) — جديد
- [docs/phase2/SCREEN_COVERAGE.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/docs/phase2/SCREEN_COVERAGE.md>) — جديد
- [docs/phase2/VERIFICATION.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/docs/phase2/VERIFICATION.md>) — جديد
- [docs/superpowers/plans/2026-11-07-phase2-complete-frontend.md](<C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE/docs/superpowers/plans/2026-11-07-phase2-complete-frontend.md>) — جديد

## المخرجات المحلية المنفصلة عن المصدر

- output/android/THRIVE-Test-development-x64.apk: بناء Test الجديد، debug x86_64.
- apps/student-mobile/build/web وapps/university-admin/dist: مخرجات البناء، مع caches/.dart_tool/obj/bin الاعتيادية داخل Test.
- .local/thrive-test/phase2-2026-11-07: لقطة الرجوع، سجلات الأدلة، الفروق والبصمات ولقطات الواجهة؛ screenshot-manifest.json يعدد كل صورة ببصمتها.
- .local/thrive-test/test-processes.json وemulator/process.json: سجلات العمليات المملوكة بعد إعادة التشغيل؛ بيانات AVD وPostgreSQL داخل Test تغيرت طبيعيًا عند التشغيل والفحص الاصطناعي.
- لم تتغير ملفات الأسرار في هذه المرحلة، ولم تُدرج قيمها في الفروق أو التقرير. هذه القائمة لا تحاول تسمية كل صفحة WAL أو ملف cache متغير كأنه ملف مصدر.

الفروق النهائية في changes.patch، ومصفوفة الملفات وبصماتها في changed-files.json وreview-head.json، داخل مجلد أدلة Phase2. Git الأب لم يُعدّل؛ لا SHA commit مختلق.

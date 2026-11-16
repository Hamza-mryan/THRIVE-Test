# مخطط الواجهات الأمامية لتطبيق THRIVE

تحديث مقارنة PDF بتاريخ 6 نوفمبر 2026: أضيفت features/activity لملخص النشاط والشعور اليومي، وfeatures/policies للخصوصية والشروط، وapp/support_path_links.dart لروابط الدعم المشتركة، وapp/student_service_scope.dart لإتاحة الاعتمادات للصفحات الفرعية. راجع PDF_REQUIREMENTS.ar.md للمطابقة التفصيلية.

يعكس الملفات الحالية للنسخة التطويرية الوظيفية بتاريخ 4 نوفمبر 2026. للمشروع واجهتان تتصلان بخادم واحد. مجلدات المنصات الأصلية موضحة كحاويات؛ build وnode_modules و.dart_tool نواتج أدوات محلية خارج هذا المخطط.

## واجهة الطالب Flutter

```text
C:\Users\hmztm\OneDrive\Documents\ChatGPT\الصحة النفسيه\THRIVE\apps\student-mobile
```

```text
student-mobile/
├── android/
├── assets/
│   └── fonts/
│       ├── NotoSansArabic-Bold.ttf
│       ├── NotoSansArabic-Regular.ttf
│       └── OFL.txt
├── ios/
├── lib/
│   ├── app/
│   │   ├── feature_scaffold.dart
│   │   ├── student_services.dart
│   │   ├── student_shell.dart
│   │   └── thrive_app.dart
│   ├── core/
│   │   └── network/
│   │       └── thrive_api.dart
│   ├── design_system/
│   │   ├── async_content.dart
│   │   ├── thrive_theme.dart
│   │   └── thrive_widgets.dart
│   ├── features/
│   │   ├── account/
│   │   │   ├── data/
│   │   │   │   └── account_repository.dart
│   │   │   └── presentation/
│   │   │       └── account_screen.dart
│   │   ├── guide/
│   │   │   ├── data/
│   │   │   │   └── guide_repository.dart
│   │   │   └── presentation/
│   │   │       └── guide_screen.dart
│   │   ├── history/
│   │   │   └── history_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── onboarding/
│   │   │   ├── application/
│   │   │   │   └── onboarding_controller.dart
│   │   │   ├── data/
│   │   │   │   └── onboarding_repository.dart
│   │   │   └── presentation/
│   │   │       ├── consent_screen.dart
│   │   │       └── welcome_screen.dart
│   │   ├── referrals/
│   │   │   ├── data/
│   │   │   │   └── referral_repository.dart
│   │   │   └── presentation/
│   │   │       └── referral_screens.dart
│   │   ├── safety/
│   │   │   └── safety_sheet.dart
│   │   └── screening/
│   │       ├── application/
│   │       │   └── screening_controller.dart
│   │       ├── data/
│   │       │   └── screening_repository.dart
│   │       └── presentation/
│   │           └── screening_screens.dart
│   ├── l10n/
│   │   ├── app_ar.arb
│   │   ├── app_en.arb
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_ar.dart
│   │   └── app_localizations_en.dart
│   └── main.dart
├── test/
│   ├── api_transport_test.dart
│   ├── functional_workflows_test.dart
│   └── onboarding_test.dart
├── web/
├── README.md
├── analysis_options.yaml
├── l10n.yaml
├── pubspec.lock
└── pubspec.yaml
```

داخل lib: app للغلاف والتنقل وربط الاعتمادات، core/network للاتصال والأخطاء، design_system للتنسيق والمكونات وحالات التحميل، features لوظائف التطبيق، وl10n للنصوص العربية والإنجليزية. تعدل ملفات ARB وتولد app_localizations تلقائيًا.

الرحلة الحالية: دخول تطويري ثم موافقات مستقلة، وخمسة تبويبات للرئيسية والسجل والموارد والإحالات والحساب. من الرئيسية تفتح Check وConnect وPlus؛ المساعدة متاحة في الغلاف والصفحات الفرعية. جلسات الفحص هنا جولة استخدام اصطناعية دون تفسير نفسي. الموارد المنشورة وحدها قابلة للتنزيل العام؛ التوكن والإجابات والنتائج لا تحفظ محليًا.

مسار العمل: Screen → Controller أو Repository الخاص بالميزة → ThriveApi → Backend. احتساب النتيجة والصلاحيات وحفظ الحالة في الخادم. الميزات البسيطة تستخدم مستودعًا وعرضًا مباشرًا، والمعقدة كالفحص تفصل حالتها في Controller.

## لوحة الجامعة Angular

```text
C:\Users\hmztm\OneDrive\Documents\ChatGPT\الصحة النفسيه\THRIVE\apps\university-admin
```

```text
university-admin/
├── public/
│   └── favicon.svg
├── src/
│   ├── app/
│   │   ├── core/
│   │   │   ├── api/
│   │   │   │   ├── admin-api.spec.ts
│   │   │   │   ├── admin-api.ts
│   │   │   │   └── models.ts
│   │   │   └── i18n/
│   │   │       ├── copy.ts
│   │   │       └── language.service.ts
│   │   ├── features/
│   │   │   ├── dashboard/
│   │   │   │   └── dashboard.page.ts
│   │   │   ├── referrals/
│   │   │   │   └── referrals.page.ts
│   │   │   ├── resources/
│   │   │   │   └── resources.page.ts
│   │   │   └── services/
│   │   │       └── services.page.ts
│   │   ├── shared/
│   │   │   ├── pending-state/
│   │   │   └── request-state/
│   │   │       ├── request-feedback.ts
│   │   │       └── request-state.ts
│   │   ├── app.config.ts
│   │   ├── app.html
│   │   ├── app.routes.ts
│   │   ├── app.scss
│   │   ├── app.spec.ts
│   │   └── app.ts
│   ├── environments/
│   │   ├── environment.demo.ts
│   │   └── environment.ts
│   ├── index.html
│   ├── main.ts
│   └── styles.scss
├── README.md
├── angular.json
├── package-lock.json
├── package.json
├── proxy.conf.json
├── tsconfig.app.json
├── tsconfig.json
└── tsconfig.spec.json
```

داخل src/app: الغلاف العام في app، core/api للعقود والاتصال وجلسة الإدارة بالذاكرة، core/i18n للنصوص واللغة، shared لحالات الطلب وملاحظاته، وfeatures لصفحات النظرة العامة والخدمات والموارد والإحالات. المسارات تحمل عند الحاجة، وواجهات الإدارة محمية أيضًا بصلاحيات الخادم.

التقارير تظهر الأعداد الصحية المحجوبة بصورة مفهومة؛ الخدمات والموارد لها نماذج إضافة وتعديل؛ حالة الإحالة تنتقل بخطوات مخولة. إعداد demo يفعّل الحساب الاصطناعي صراحة، وإعدادات development وproduction العادية لا تفعّله.

## نقاط التعديل

- التصميم المشترك للطالب: lib/design_system. النصوص: lib/l10n/*.arb.
- تنقل الطالب: lib/app/student_shell.dart وlib/app/thrive_app.dart.
- تصميم الإدارة: src/styles.scss وتنسيقات الغلاف والمكونات. النصوص: src/app/core/i18n/copy.ts.
- تنقل الإدارة: src/app/app.routes.ts. عقود الاتصال: src/app/core/api/models.ts وadmin-api.ts.
- مواصفة API المشتركة في THRIVE/contracts/openapi، وتصدر من Backend.
- التشغيل الموحد من جذر THRIVE: scripts/start-project.ps1 -EnableDevelopmentIdentity. الإيقاف: scripts/stop-project.ps1.

راجع README لكل تطبيق وحالة التنفيذ لمعرفة حدود التشغيل التجريبي وإعدادات Android وSSO والأدوات السريرية.

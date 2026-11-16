# نقل THRIVE Test لعرضه على جهاز Windows آخر

التاريخ: 16 نوفمبر 2026. العرض المقصود: 17 نوفمبر 2026. نوع الجهاز الآخر غير محدد بدقة بين Windows 10 و11، ولم نختبره عليه بعد.

**لا تعتبر النسخة جاهزة للعرض على الجهاز الثاني قبل تشغيلها عليه فعليًا.** المستودع يحتوي مصدر المشروع وتعليماته؛ ليس برنامج تثبيت أو تطبيقًا يعمل بالنقر مرتين. لا يتضمن SDKs أو قاعدة البيانات أو التبعيات المحملة. يلزم اتصال بالإنترنت لاستعادة الحزم عند أول إعداد.

نزّل المستودع باستخدام Git أو خيار **Code → Download ZIP** في GitHub ثم فك الضغط. افتح PowerShell داخل مجلد `THRIVE` الموجود تحت جذر المستودع، وليس في المجلد الأب. Git مطلوب للاستنساخ فقط؛ تنزيل ZIP بديل لنقل المصدر.

## طريقة العرض المقترحة

استخدم المتصفح لواجهة الطالب ولوحة الإدارة. هذا يتجنب إعداد Android Studio والمحاكي، لكن تشغيل الرحلات التفاعلية ما زال يحتاج Backend وقاعدة PostgreSQL مستقلين على الجهاز نفسه. ملف APK وحده لا يوفرهما.

نسخة المصدر النظيفة تستبعد `.local` وملفات `.env.local` وقواعد البيانات و`node_modules` وملفات البناء. لا تنقل هذه الملفات من الجهاز الحالي؛ سجلات الملكية مرتبطة بالمسار والجهاز، وتُنشأ من جديد في الجهاز الآخر. بيانات العرض اصطناعية فقط.

## المتطلبات

- Windows بنظام 64 بت، ومتصفح Edge أو Chrome حديث. يلزم التحقق من توافق إصدار Windows الفعلي مع الأدوات؛ اسم Windows 10 أو11 وحده لا يثبت الجاهزية.
- [.NET SDK](https://learn.microsoft.com/en-us/dotnet/core/install/windows) بالإصدار المثبت في `services/backend/global.json`: حاليًا 10.0.403 أو patch يقبله ذلك الملف. Runtime وحده لا يكفي للبناء وأول migration.
- [Node.js](https://nodejs.org/en/download) بإصدار يطابق `apps/university-admin/package.json`: حاليًا `^22.22.3 || ^24.15.0 || >=26.0.0`، مع npm.
- [Flutter SDK](https://docs.flutter.dev/install) بالإصدار المثبت في `apps/student-mobile/.flutter-version`: حاليًا 3.47.9.
- [PostgreSQL 17 binaries](https://www.postgresql.org/download/windows/)؛ يجب أن تتوفر `psql` و`pg_ctl` و`initdb` و`createdb` من المجلد نفسه. أضف مجلد `bin` للأدوات إلى PATH في نافذة العمل. السكربت سيستخدمها لإنشاء cluster خاص بالمشروع على 55432؛ لا تعدّل قاعدة PostgreSQL أخرى.

افتح PowerShell داخل `<مجلد المستودع>\THRIVE`. عند الحاجة للسماح بالسكربتات المحلية في هذه النافذة فقط:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

ثم شغّل التشخيص الذي لا يغيّر إعدادات الجهاز أو البيانات:

```powershell
.\scripts\check-presentation-environment.ps1
```

وجود الأدوات لا يثبت صحة إصداراتها. للتأكد استخدم `dotnet --list-sdks` و`node --version` و`npm --version` و`flutter --version` و`psql --version`، وقارنها بالملفات المثبتة أعلاه.

إذا أشار التشخيص إلى Smart App Control، قد يمنع Backend غير الموقّع كما حدث على الجهاز الأول. لا توجد استثناءات لتطبيق واحد ضمنه وفق [Microsoft](https://support.microsoft.com/en-us/windows/security/threat-malware-protection/smart-app-control-frequently-asked-questions). سكربتات المشروع لا تغيّر الحماية؛ يلزم حسم هذا العائق قبل موعد العرض. لا تعتمد على تغيير اسم المجلد لحله.

## أول إعداد في نسخة المصدر النظيفة على الجهاز الثاني فقط

هذه الخطوات تنشئ موارد Test جديدة؛ لم تُنفذ على الجهاز الثاني في هذه الجلسة. لا تستخدم خطوة migration التالية لإعادة فحص المجلد الموجود على الجهاز الأول.

```powershell
.\scripts\initialize-local.ps1
.\scripts\start-database.ps1
```

يجب أن يظهر التحقق من `thrive_test` و`thrive_test_local` على `127.0.0.1:55432`. إذا رُفضت الملكية أو ظهر تعارض منافذ، توقف وراجع السبب؛ لا تحذف سجلات أو تغيّر وجهة الاتصال لتجاوز الفحص.

استعد تبعيات الواجهتين داخل المشروع:

```powershell
Push-Location .\apps\university-admin
try { npm.cmd ci } finally { Pop-Location }

. .\scripts\lib\FlutterEnvironment.ps1
$tooling = Get-ThriveFlutterTooling (Get-Location).Path
Push-Location $tooling.Workspace
try { & $tooling.Executable pub get --enforce-lockfile } finally { Pop-Location }
```

أول تشغيل للـBackend، بعد تحقق ملكية **قاعدة Test الجديدة**، يحتاج إنشاء مخططها من migrations المعتمدة:

```powershell
.\scripts\start-backend.ps1 -EnableDevelopmentIdentity -ApplyMigrations
```

السكربت يتحقق من قاعدة الاختبار ومالكها ومجلد بياناتها قبل تطبيق migrations. اترك النافذة مفتوحة. في التشغيل التالي استخدم الأمر نفسه دون `-ApplyMigrations`.

افتح نافذتين إضافيتين داخل مجلد `THRIVE` نفسه، مع السماح المؤقت بالسكربتات إذا احتاجت كل نافذة ذلك:

```powershell
.\scripts\start-student.ps1 -EnableDevelopmentIdentity
```

```powershell
.\scripts\start-admin.ps1 -EnableDevelopmentIdentity
```

- الطالب: `http://localhost:5400`
- الإدارة: `http://localhost:4300`
- جاهزية Backend: `http://localhost:5280/health/ready`
- هوية الاتصال: `http://localhost:5280/health/isolation`

لا يكفي ظهور الواجهة؛ يجب أن تعمل `/health/ready` وتعرض `/health/isolation` هوية THRIVE Test وقاعدة الاختبار.

## تجربة قبل مقابلة الدكتور

1. افتح جاهزية Backend، ثم سجّل دخولًا تجريبيًا من الطالب والإدارة.
2. وافق على استخدام الخدمة، مع ترك خيار البحث مستقلًا حسب الاختيار.
3. أكمل جولة DEMO-CHECK واحفظها، ثم تحقق من النتيجة والسجل. النتيجة تقنية وغير سريرية.
4. افتح موردًا من الدليل وخدمة تجريبية، وتحقق من ظهور البيانات في لوحة الإدارة. لا تتواصل مع جهة خارجية.
5. أعد فتح التطبيق وتأكد من إمكانية الدخول واسترجاع السجل الاصطناعي.

إذا فشلت خطوة، فالعرض التفاعلي غير مؤكد حتى إصلاحها. احتفظ بنتيجة التشخيص وآخر رسالة خطأ، وأجرِ التجربة قبل الموعد بوقت كافٍ. للإيقاف اضغط Ctrl+C في نوافذ الأجزاء؛ قاعدة Test يمكن إيقافها لاحقًا عبر `scripts/stop-database.ps1` بعد إيقاف التطبيقات.

## حدود التحقق

تمت إعادة تشغيل Test على الجهاز الأول، واستجابت جاهزية Backend والواجهتان، وأكد المستخدم عمل التطبيق على المحاكي. لم تُجرَ تجربة الجهاز الثاني بعد. لا يتضمن المستودع حزمة تثبيت جاهزة أو ألبوم صور احتياطيًا. تقارير المراحل السابقة توثق نتائجها التاريخية، ولا تعني اكتمال جميع فحوص المرحلة الثالثة أو الاعتماد السريري.

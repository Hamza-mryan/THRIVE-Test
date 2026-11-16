# تشغيل THRIVE Test على هذا الجهاز

هذه تعليمات النسخة التجريبية المعزولة فقط. التفاصيل ونتائج الفحص في [تقرير العزل](TEST_ISOLATION.ar.md).

لتجربة النسخة الموجودة دون تشغيل migrations، افتح PowerShell داخل هذا المجلد:

~~~powershell
Set-Location 'C:\Users\hmztm\OneDrive\Desktop\New folder\الصحة النفسيه\THRIVE'
.\scripts\start-database.ps1
.\scripts\start-backend.ps1 -EnableDevelopmentIdentity
~~~

اترك نافذة Backend مفتوحة. إذا لم تكن الواجهتان تعملان، شغّل كل واحدة في نافذة مستقلة من المجلد نفسه:

~~~powershell
.\scripts\start-student.ps1 -EnableDevelopmentIdentity
~~~

~~~powershell
.\scripts\start-admin.ps1 -EnableDevelopmentIdentity
~~~

إذا منع Windows PowerShell تشغيل ملفات `.ps1`، يمكن السماح بالسكربتات المحلية لهذه النافذة فقط باستخدام `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned`؛ ينتهي هذا التغيير عند إغلاقها، وتظل سياسات المؤسسة أعلى أولوية. [توثيق Microsoft](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies).

تصحيح 16 نوفمبر 2026: تقرأ سكربتات التشغيل سجلات الملكية والإعدادات بترميز UTF-8 صريح؛ كان Windows PowerShell 5.1 يفسر المسار العربي المخزن دون BOM بترميز ANSI، فيرفض سجل الملكية الصحيح. لا يتطلب التصحيح تغيير اسم المجلد أو إعادة إنشاء البيئة أو تعديل سجل الملكية. تبقى فحوص المسار ومعرّف النسخة وقاعدة البيانات فعالة. [توثيق الترميز](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-5.1).

حظر `Application Control policy has blocked this file` أثناء تحميل Backend عائق منفصل رُصد على هذا الجهاز؛ تصحيح قراءة الملفات لا يزيله. لا تعتبر استجابة الواجهة وحدها دليلًا على جاهزية Backend؛ افحص `http://localhost:5280/health/ready` بعد تشغيله.

| الجزء | العنوان |
|---|---|
| تطبيق الطالب | http://localhost:5400 |
| لوحة الإدارة | http://localhost:4300 |
| Backend | http://localhost:5280 |
| هوية الاتصال الفعلي | http://localhost:5280/health/isolation |
| PostgreSQL | 127.0.0.1:55432 / thrive_test |

يمكن إبقاء الأصل يعمل على 5180 و5300 و4200 و5432. لا توقفه لحل تعارض في منافذ الاختبار؛ المشغّل يرفض المنفذ المشغول دون قتل صاحبه.

أدوات SDK الموجودة مشتركة للقراءة، لكن قاعدة الاختبار ومخرجات البناء وGradle وسجل العمليات تخص هذا المجلد. يستخدم Windows حرف قرص افتراضيًا إلى هذا المجلد فقط لتجاوز مشكلة الأحرف العربية؛ لا يعيد استخدام رابط Flutter الخاص بالأصل.

الدخول التجريبي يستخدم شخصيات وهمية ثابتة داخل قاعدة الاختبار وحدها. تظل التوكنات في الذاكرة، وتبطل عند إعادة تشغيل Backend. لا تستخدم بيانات طلاب حقيقية.

في التشغيل اليدوي أعلاه تظهر السجلات في نافذة كل جزء. عند استخدام المشغّل الشامل `start-project.ps1` يسجل العمليات ويكتب السجلات في `.local/thrive-test/` بأسماء backend وstudent وadmin مع .log و.error.log؛ هذا المشغّل يطبق migrations بعد التحقق، لذلك لا يُستخدم للفحص البصري أو إعادة تجربة البيئة الموجودة.

~~~powershell
node scripts/verify-isolation.mjs
node scripts/verify-development.mjs
~~~

الأمر الثاني يكتب سجلات اصطناعية في thrive_test بعد التحقق من هوية الخادم الفعلية. يرفض عنوان API الأصلي قبل إرسال أي طلب.

لإيقاف الأجزاء التي شغّلتها يدويًا، اضغط `Ctrl+C` داخل نافذة كل جزء. لإيقاف العمليات التي سجلها المشغّل الشامل سابقًا، مع إبقاء PostgreSQL:

~~~powershell
.\scripts\stop-project.ps1
~~~

إيقاف PostgreSQL الخاص بهذه النسخة بعد التحقق من ملكيته، دون حذف البيانات:

~~~powershell
.\scripts\stop-database.ps1
~~~

بناء Android لمحاكي x86_64:

~~~powershell
.\scripts\build-android-debug.ps1 -EnableDevelopmentIdentity -TargetPlatform android-x64
~~~

الناتج output/android/THRIVE-Test-development-x64.apk، ومعرّفه edu.thrive.thrive_student.test، وعنوانه الافتراضي http://10.0.2.2:5280. لا تثبّت ملفات APK القديمة المنسوخة باعتبارها نسخة Test.

لجهاز موصول تختاره صراحة عبر SERIAL:

~~~powershell
adb -s SERIAL reverse tcp:5280 tcp:5280
.\scripts\build-android-debug.ps1 -EnableDevelopmentIdentity -ApiBaseUrl http://localhost:5280
~~~

هذه تعليمات الجهاز الفعلي؛ نتيجة التحقق المنفذة تخص المحاكي كما يوثق تقرير العزل. بناء iOS يحتاج macOS/Xcode.

using Microsoft.EntityFrameworkCore;
using Thrive.Domain.Catalog;

namespace Thrive.Infrastructure.Persistence;

// Called only by the development-identity gate; never runs against production automatically.
public static class DemoCatalogSeeder
{
    private static readonly SemaphoreSlim Gate = new(1, 1);
    public static async Task SeedAsync(ThriveDbContext db, string university, CancellationToken ct)
    {
        await Gate.WaitAsync(ct);
        try
        {
            if (!await db.UniversityServices.AnyAsync(x => x.UniversityId == university, ct))
                foreach (var level in new[] { "Counseling", "Specialist" })
                    db.UniversityServices.Add(new UniversityService
                    {
                        UniversityId = university,
                        Level = level,
                        IsDemo = true,
                        Active = true,
                        NameAr = level == "Counseling" ? "خدمة جامعية افتراضية للتجربة" : "خدمة تخصصية افتراضية للتجربة",
                        NameEn = level == "Counseling" ? "Simulated university service" : "Simulated specialist service",
                        DescriptionAr = "جهة اصطناعية لاختبار طلب الإحالة فقط. ليست جهة رعاية فعلية.",
                        DescriptionEn = "A synthetic service to test referral workflows. This is not an operational care provider.",
                        HoursAr = "غير مطبق في التجربة",
                        HoursEn = "Not applicable in this demo",
                        LocationAr = "خدمة افتراضية",
                        LocationEn = "Simulated location",
                        BookingMethod = "Development request only",
                        Source = "THRIVE synthetic product walkthrough"
                    });
            if (!await db.GuideResources.AnyAsync(x => x.UniversityId == university, ct))
                foreach (var topic in new[] { "start", "privacy", "referrals" })
                    db.GuideResources.Add(new GuideResource
                    {
                        UniversityId = university,
                        Slug = $"demo-{topic}",
                        IsDemo = true,
                        Published = true,
                        Category = "Using THRIVE",
                        Version = "demo-1",
                        Source = "THRIVE product walkthrough (development copy)",
                        TitleAr = topic switch { "start" => "كيف تستخدم النسخة التجريبية", "privacy" => "خيارات الموافقة والخصوصية", _ => "كيف تتابع طلب الإحالة" },
                        TitleEn = topic switch { "start" => "Using the development preview", "privacy" => "Consent and privacy choices", _ => "Following a referral request" },
                        SummaryAr = "دليل استخدام للمنتج في بيئة التطوير، دون نصائح علاجية.",
                        SummaryEn = "A product guide for the development environment, without treatment advice.",
                        BodyAr = topic switch { "start" => "ابدأ بقراءة سياسة الموافقة. يمكنك ترك المشاركة البحثية غير محددة. الجولة التجريبية تختبر وضوح استخدام التطبيق ولا تقيس الصحة النفسية. الموارد والإحالات المعروضة في هذه البيئة اصطناعية وموسومة بوضوح.", "privacy" => "موافقة استخدام الخدمة منفصلة عن البحث. يمكنك مراجعة خياراتك من الحساب وسحب موافقة الخدمة. عند السحب يتوقف الوصول للمسارات المرتبطة بالخدمة حتى قبولها مجددًا. بيانات هذه التجربة اصطناعية.", _ => "اختر خدمة تجريبية واقرأ بياناتها، ثم وافق على مشاركة الحد الأدنى قبل طلب الإحالة. الطلب لا يعني حجز موعد. تتغير الحالة حسب معالجة المشغل التجريبي، ويمكن إلغاء الطلب قبل نهايته. لا ترسل هذه البيئة إشعارات أو رسائل خارجية." },
                        BodyEn = topic switch { "start" => "Read the consent policy first. You may leave research participation unchecked. The usability demo tests the application workflow, not mental health. Resources and referral services in this environment are synthetic and clearly labeled.", "privacy" => "Service consent is separate from research. Review your choices in Account and withdraw service consent when desired. Withdrawal disables service pathways until you accept service consent again. Data used here is synthetic.", _ => "Choose a simulated service, review its details, and consent to minimum information sharing before requesting a referral. A request does not confirm an appointment. The development operator updates its status; you may cancel before a terminal status. No external messages are sent." }
                    });
            await DemoWellbeingResources.SeedAsync(db, university, ct);
            await db.SaveChangesAsync(ct);
        }
        finally { Gate.Release(); }
    }
}

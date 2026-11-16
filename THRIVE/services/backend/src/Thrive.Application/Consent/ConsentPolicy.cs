namespace Thrive.Application.Consent;

public sealed record ConsentPolicy(
    string Version, string ServiceTextAr, string ServiceTextEn,
    string ResearchTextAr, string ResearchTextEn)
{
    // Draft copy supports development only; institutional/legal review precedes a student pilot.
    public static ConsentPolicy Current { get; } = new(
        "draft-2026-11-03",
        "نص تجريبي للمراجعة: THRIVE أداة فحص وإحالة وليست للتشخيص أو العلاج. تُستخدم بياناتك لتقديم الخدمة وفق سياسة الجامعة التي ستعتمد قبل الإطلاق.",
        "Draft for review: THRIVE supports screening and referral, not diagnosis or treatment. Your data supports the service under a university policy that must be approved before launch.",
        "المشاركة البحثية اختيارية ومستقلة عن استخدام الخدمة. رفضها لا يمنع الحصول على الدعم. هذا نص تجريبي ينتظر الاعتماد.",
        "Research participation is optional and separate from service use. Declining does not prevent support. This draft requires institutional approval.");
}

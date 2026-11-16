using Thrive.Contracts;
using Thrive.Domain.Catalog;
using Thrive.Domain.Referrals;
using Thrive.Domain.Screening;
using Thrive.Application.Screening;

namespace Thrive.Api.Endpoints;

public static class FeatureMapping
{
    public static ScreeningResultResponse Result(ScreeningSession x) => new(x.Id, x.InstrumentCode, "Demo", x.RawScore!.Value, DemoInstrument.Definition.Items.Sum(item => item.Options.Max(option => option.Value)), x.InstrumentVersion,
        "تم تسجيل إجابات الجولة التجريبية. المجموع تقني فقط ولا يمثل فحصًا نفسيًا أو تشخيصًا أو مستوى خطر.",
        "The development usability responses were recorded. This technical total is not a mental-health screen, diagnosis or risk level.", x.CompletedAtUtc!.Value, true);
    public static SessionResponse Session(ScreeningSession x) => new(x.Id, x.InstrumentCode, x.InstrumentVersion, x.CompletedAtUtc is null ? "InProgress" : "Completed", x.StartedAtUtc, x.CompletedAtUtc, x.Answers.Select(a => new AnswerResponse(a.ItemCode, a.Value)).ToArray(), x.CompletedAtUtc is null ? null : Result(x));
    public static ServiceResponse Service(UniversityService x) => new(x.Id, x.Level, x.NameAr, x.NameEn, x.DescriptionAr, x.DescriptionEn, x.HoursAr, x.HoursEn, x.LocationAr, x.LocationEn, x.BookingMethod, x.ContactUrl, x.IsDemo, x.Verified, x.Active, x.Phone, x.Email, x.Specialty, x.Source);
    public static ResourceResponse Resource(GuideResource x) => new(x.Id, x.Slug, x.TitleAr, x.TitleEn, x.SummaryAr, x.SummaryEn, x.BodyAr, x.BodyEn, x.Category, x.Source, x.ReviewedAtUtc, x.Version, x.IsDemo, x.Published);
    public static ReferralResponse Referral(Referral x) => new(x.Id, x.ServiceId, x.ServiceNameAr, x.ServiceNameEn, x.Level, x.Status, x.CreatedAtUtc, x.UpdatedAtUtc, x.IsDemo);
}

using Microsoft.EntityFrameworkCore;
using Thrive.Domain.Catalog;

namespace Thrive.Infrastructure.Persistence;

// Educational drafts for the development catalog, never a claim of clinical review.
// Called only inside the existing development-identity seed gate.
internal static class DemoWellbeingResources
{
    public static async Task SeedAsync(ThriveDbContext db, string university, CancellationToken ct)
    {
        var existing = await db.GuideResources.Where(x => x.UniversityId == university)
            .Select(x => x.Slug).ToListAsync(ct);
        foreach (var draft in Drafts())
        {
            if (existing.Contains(draft.Slug)) continue;
            draft.UniversityId = university;
            draft.IsDemo = true;
            draft.Published = true;
            draft.Version = "education-draft-1";
            draft.ReviewedAtUtc = null;
            db.GuideResources.Add(draft);
        }
    }

    private static GuideResource[] Drafts() =>
    [
        new()
        {
            Slug = "draft-stress", Category = "Stress",
            TitleAr = "خفّف الحمل، خطوة بخطوة", TitleEn = "A little less pressure, one step at a time",
            SummaryAr = "ابدأ بشيء صغير يمكنك إنجازه اليوم.", SummaryEn = "Start with one small, manageable step today.",
            BodyAr = "قسّم المطلوب إلى خطوات صغيرة. اختر ما تستطيع تغييره، وشارك شعورك مع شخص تثق به. إذا كان التوتر يؤثر في يومك، اطلب دعمًا بشريًا.\n\nهذه صياغة تثقيفية أولية بانتظار مراجعة مختص الجامعة، وليست علاجًا أو نصًا معتمدًا.",
            BodyEn = "Break tasks into small steps. Focus on what you can change and talk to someone you trust. Seek support when stress affects daily life.\n\nThis educational draft is pending university specialist review; it is not treatment or approved clinical content.",
            Source = "https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/stress/"
        },
        new()
        {
            Slug = "draft-exams", Category = "Exams",
            TitleAr = "مساحة أهدأ قبل الامتحان", TitleEn = "A calmer space before exams",
            SummaryAr = "خطة واقعية ودعم خلال الدراسة.", SummaryEn = "Realistic study plans and support.",
            BodyAr = "قسّم الدراسة إلى أجزاء يمكنك إدارتها، واترك وقتًا للراحة والنوم. تحدّث مع صديق أو مرشد جامعي عندما تحتاج الدعم.\n\nمسودة تثقيفية بانتظار مراجعة مختص الجامعة، وليست علاجًا.",
            BodyEn = "Plan study in manageable chunks and leave time for rest and sleep. Talk with a friend or university tutor when you need support.\n\nEducational draft pending university specialist review; not treatment.",
            Source = "https://www.nhs.uk/mental-health/children-and-young-adults/help-for-teenagers-young-adults-and-students/student-stress-self-help-tips/"
        },
        new()
        {
            Slug = "draft-sleep", Category = "Sleep",
            TitleAr = "امنح يومك نهاية هادئة", TitleEn = "Give your day a gentler ending",
            SummaryAr = "عادات بسيطة للنوم والراحة.", SummaryEn = "Simple habits for sleep and rest.",
            BodyAr = "جرّب وقتًا منتظمًا للنوم والاستيقاظ، وروتينًا هادئًا قبل النوم. هيّئ مكانًا مريحًا ومظلمًا وهادئًا. إذا استمرت صعوبة النوم وأثرت في يومك، استشر مختصًا.\n\nمسودة تثقيفية بانتظار مراجعة مختص الجامعة، وليست علاجًا.",
            BodyEn = "Try regular sleep and wake times and a quiet wind-down routine. Make your room comfortable, dark and quiet. Seek professional advice if ongoing sleep problems affect daily life.\n\nEducational draft pending university specialist review; not treatment.",
            Source = "https://www.nhs.uk/every-mind-matters/mental-wellbeing-tips/how-to-fall-asleep-faster-and-sleep-better/"
        },
        new()
        {
            Slug = "draft-time", Category = "Time",
            TitleAr = "خطتك تبدأ بمهمة واحدة", TitleEn = "Your plan starts with one task",
            SummaryAr = "حوّل المهام الكبيرة إلى خطوات أقرب.", SummaryEn = "Turn large tasks into smaller steps.",
            BodyAr = "اكتب ما تحتاج إنجازه وحدد خطوة صغيرة للبدء. خطط مسبقًا للأيام المزدحمة بدل محاولة إنجاز كل شيء دفعة واحدة.\n\nمسودة تثقيفية بانتظار مراجعة مختص الجامعة، وليست علاجًا.",
            BodyEn = "List what you need to do and choose a small starting step. Plan ahead for busy days rather than trying to do everything at once.\n\nEducational draft pending university specialist review; not treatment.",
            Source = "https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/stress/"
        },
        new()
        {
            Slug = "draft-breathing", Category = "Breathing",
            TitleAr = "لحظة للتنفّس بلطف", TitleEn = "A moment to breathe gently",
            SummaryAr = "تنفّس مريح دون إجبار أو حبس النفس.", SummaryEn = "Comfortable breathing without forcing or holding.",
            BodyAr = "اجلس براحة ودع التنفس يتدفق دون إجبار. تنفّس بلطف عبر الأنف وأخرج الهواء عبر الفم. يمكنك العد ببطء حتى خمسة إذا كان ذلك مريحًا.\n\nمسودة تثقيفية بانتظار مراجعة مختص الجامعة، وليست علاجًا أو أداة للاستجابة للطوارئ.",
            BodyEn = "Sit comfortably and let your breath flow without forcing it. Breathe gently in through your nose and out through your mouth. Count slowly up to five if comfortable.\n\nEducational draft pending university specialist review; not treatment or an emergency response tool.",
            Source = "https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/breathing-exercises-for-stress/"
        },
        new()
        {
            Slug = "draft-grounding", Category = "Grounding",
            TitleAr = "ارجع للحظة الموجودة حولك", TitleEn = "Reconnect with the moment around you",
            SummaryAr = "تعرّف على التأريض ومصادره العامة.", SummaryEn = "Explore grounding and its public sources.",
            BodyAr = "يقدّم دليل منظمة الصحة العالمية التأريض كمهارة للعودة للحاضر خلال التوتر، إلى جانب ملاحظة الأفكار والتعامل مع النفس بلطف.\n\nهذه مقدمة أولية وليست ترجمة أو إعادة نشر لتمرين الدليل. استخدم رابط المصدر للاطلاع على المادة الأصلية. بانتظار مراجعة مختص الجامعة.",
            BodyEn = "WHO describes grounding as a skill for reconnecting with the present during stress, alongside noticing thoughts and practising kindness.\n\nThis introduction is not a translation or reproduction of the guide's exercises. Open the source for the original material. University specialist review is pending.",
            Source = "https://www.who.int/thailand/activities/doing-what-matters-in-times-of-stress"
        }
    ];
}

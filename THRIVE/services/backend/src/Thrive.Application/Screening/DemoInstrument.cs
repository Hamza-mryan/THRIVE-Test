namespace Thrive.Application.Screening;

public sealed record InstrumentOption(int Value, string LabelAr, string LabelEn);
public sealed record InstrumentItem(string Code, string PromptAr, string PromptEn, InstrumentOption[] Options);
public sealed record Instrument(string Code, string TitleAr, string TitleEn, string Version, bool IsDemo, InstrumentItem[] Items);

public static class DemoInstrument
{
    public const string Code = "DEMO-CHECK";
    public const string Version = "demo-usability-1";
    private static readonly InstrumentOption[] Options =
    [new(0, "غير واضح", "Not clear"), new(1, "واضح جزئيًا", "Partly clear"), new(2, "واضح", "Clear")];
    public static Instrument Definition => new(Code, "جولة تجريبية لاستخدام التطبيق", "Application usability demo", Version, true,
    [new("navigation", "هل خطوات التنقل في هذه الجولة واضحة؟", "Are the navigation steps in this demo clear?", Options),
     new("consent", "هل الفرق بين موافقة الخدمة والبحث واضح؟", "Is the distinction between service and research consent clear?", Options),
     new("support", "هل مكان زر المساعدة في التطبيق واضح؟", "Is the help button's location clear?", Options)]);
}

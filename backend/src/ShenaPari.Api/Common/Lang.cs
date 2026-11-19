using System.Globalization;

namespace ShenaPari.Api.Common;

/// The language of the current request (Accept-Language: uk or en).
public static class Lang
{
    public static bool IsEnglish => CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "en";

    /// A text the admin entered in both languages: the English one when it was asked for
    /// and filled in, otherwise the Ukrainian one.
    public static string Pick(string uk, string? en) => IsEnglish && !string.IsNullOrWhiteSpace(en) ? en : uk;

    public static string? PickOptional(string? uk, string? en) => IsEnglish && !string.IsNullOrWhiteSpace(en) ? en : uk;
}

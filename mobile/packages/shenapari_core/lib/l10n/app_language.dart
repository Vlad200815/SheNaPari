/// The language picked in «Налаштування → Мова».
enum AppLanguage {
  /// Follow the phone: Ukrainian or English, whichever the phone uses.
  system,
  uk,
  en;

  /// What is stored in the prefs; anything unknown means [system].
  static AppLanguage parse(String? value) =>
      values.asNameMap()[value] ?? system;
}

/// The languages the app has texts for.
const supportedLanguageCodes = ['uk', 'en'];

/// The language the app shows. For [AppLanguage.system] it is the phone's
/// own if the app has it, English otherwise (the app has no third language,
/// and English is the one a non-Ukrainian phone most likely reads).
String resolveLanguageCode(AppLanguage choice, String deviceLanguageCode) =>
    switch (choice) {
      AppLanguage.uk => 'uk',
      AppLanguage.en => 'en',
      AppLanguage.system =>
        supportedLanguageCodes.contains(deviceLanguageCode)
            ? deviceLanguageCode
            : 'en',
    };

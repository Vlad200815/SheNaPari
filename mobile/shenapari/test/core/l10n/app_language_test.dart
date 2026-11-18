import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/l10n/app_language.dart';

void main() {
  group('resolveLanguageCode', () {
    test('a picked language wins over the phone', () {
      expect(resolveLanguageCode(AppLanguage.uk, 'en'), 'uk');
      expect(resolveLanguageCode(AppLanguage.en, 'uk'), 'en');
    });

    test('system: the phone language if the app has it', () {
      expect(resolveLanguageCode(AppLanguage.system, 'uk'), 'uk');
      expect(resolveLanguageCode(AppLanguage.system, 'en'), 'en');
    });

    test('system: English for a language the app does not have', () {
      expect(resolveLanguageCode(AppLanguage.system, 'de'), 'en');
      expect(resolveLanguageCode(AppLanguage.system, 'pl'), 'en');
    });
  });

  test('an unknown stored value means system', () {
    expect(AppLanguage.parse(null), AppLanguage.system);
    expect(AppLanguage.parse('fr'), AppLanguage.system);
    expect(AppLanguage.parse('en'), AppLanguage.en);
  });
}

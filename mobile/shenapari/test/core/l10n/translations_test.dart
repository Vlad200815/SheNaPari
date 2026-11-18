import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/l10n/l10n.dart';
import 'package:shenapari/core/result/failure.dart';

import '../../l10n_helper.dart';

Set<String> _keys(Map<String, dynamic> map, [String prefix = '']) => {
  for (final MapEntry(:key, :value) in map.entries)
    if (value is Map<String, dynamic> && !value.containsKey('other'))
      ..._keys(value, '$prefix$key.')
    else
      '$prefix$key',
};

void main() {
  tearDown(loadTestTranslations);

  // The other tests read the files from the disk; the app reads them from
  // its asset bundle, which has them only if pubspec.yaml declares them.
  test('the translations are bundled with the app', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final code in ['uk', 'en']) {
      final json = await rootBundle.loadString(
        'assets/translations/$code.json',
      );
      expect(json, contains('"app"'));
    }
  });

  test('uk and en have the same keys', () {
    expect(_keys(readTranslations('en')), _keys(readTranslations('uk')));
  });

  test('no Cyrillic letters slipped into en.json', () {
    final en = readTranslations('en').toString();
    expect(RegExp('[Ѐ-ӿ]').hasMatch(en), isFalse);
  });

  test('Ukrainian plurals: 1 порція, 2 порції, 5 порцій, 11, 21', () {
    String portions(int n) => LocaleKeys.cart_portions.plural(n);
    expect(portions(1), 'порція');
    expect(portions(2), 'порції');
    expect(portions(5), 'порцій');
    expect(portions(11), 'порцій');
    expect(portions(21), 'порція');
  });

  test('English plurals', () {
    loadTestTranslations('en');
    expect(LocaleKeys.cart_portions.plural(1), 'portion');
    expect(LocaleKeys.cart_portions.plural(3), 'portions');
  });

  test('failures made on the client get a text in the current language', () {
    expect(const NetworkFailure().text, 'Немає з’єднання з сервером');
    expect(const UnexpectedFailure('').text, startsWith('Щось пішло не так'));
    expect(const ConflictFailure('Від сервера').text, 'Від сервера');

    loadTestTranslations('en');
    expect(const NetworkFailure().text, 'No connection to the server');
  });
}

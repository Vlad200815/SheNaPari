import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari_core/l10n/core_keys.dart';

import '../l10n_helper.dart';

Set<String> _keys(Map<String, dynamic> map, [String prefix = '']) => {
  for (final MapEntry(:key, :value) in map.entries)
    if (value is Map<String, dynamic> && !value.containsKey('other'))
      ..._keys(value, '$prefix$key.')
    else
      '$prefix$key',
};

void main() {
  test('the translations are bundled with the app', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final code in ['uk', 'en']) {
      final json = await rootBundle.loadString(
        'assets/translations/$code.json',
      );
      expect(json, contains('"login"'));
    }
  });

  test('uk and en have the same keys', () {
    expect(_keys(readTranslations('en')), _keys(readTranslations('uk')));
  });

  test('the keys the shared package uses are here too', () {
    for (final code in ['uk', 'en']) {
      expect(_keys(readTranslations(code)), containsAll(CoreKeys.all));
    }
  });
}

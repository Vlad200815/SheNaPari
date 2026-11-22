import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/app/di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari_core/l10n/app_locale.dart';
import 'package:shenapari_core/l10n/core_keys.dart';
import 'package:shenapari_core/storage/in_memory_token_storage.dart';

import '../l10n_helper.dart';

Set<String> _keys(Map<String, dynamic> map, [String prefix = '']) => {
  for (final MapEntry(:key, :value) in map.entries)
    if (value is Map<String, dynamic> && !value.containsKey('other'))
      ..._keys(value, '$prefix$key.')
    else
      '$prefix$key',
};

void main() {
  test('the Ukrainian texts are bundled with the app', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final json = await rootBundle.loadString('assets/translations/uk.json');
    expect(json, contains('"login"'));
  });

  test('Ukrainian only: no other translations', () {
    final files = Directory(
      'assets/translations',
    ).listSync().map((f) => f.uri.pathSegments.last).toList();
    expect(files, ['uk.json']);
  });

  test('the keys the shared package uses are here too', () {
    expect(_keys(readTranslations('uk')), containsAll(CoreKeys.all));
  });

  test('Ukrainian even on an English tablet, for the server too', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    setupDi(
      prefs: await SharedPreferences.getInstance(),
      tokenStorage: InMemoryTokenStorage(),
    );
    addTearDown(sl.reset);

    expect(sl<AppLocale>().languageCode, 'uk');
  });
}

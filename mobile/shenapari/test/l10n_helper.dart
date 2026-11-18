import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';

/// Reads `assets/translations/<code>.json` straight from the disk: no
/// asset bundle, no real async work inside a widget test's fake time.
class FileAssetLoader extends AssetLoader {
  const FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) =>
      Future.value(readTranslations(locale.languageCode));
}

Map<String, dynamic> readTranslations(String code) =>
    jsonDecode(File('assets/translations/$code.json').readAsStringSync())
        as Map<String, dynamic>;

/// Makes `tr()` work in plain tests too (no EasyLocalization widget).
void loadTestTranslations([String code = 'uk']) {
  Localization.load(
    Locale(code),
    translations: Translations(readTranslations(code)),
    ignorePluralRules: false,
  );
}

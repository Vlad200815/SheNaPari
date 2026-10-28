import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/generated/codegen_loader.g.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';

class Localization {
  static const PREF_LOCALE = "locale";
  static const DIRECTORY = "assets/translations";
  static const DEFAULT_LANGUAGE = "en";

  static Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    final language = preferences.get(PREF_LOCALE);
    final isNotFoundLocale = language == null;
    if (isNotFoundLocale) {
      final foundPlatformLocale = await _findSystemLocale();
      preferences.setString(PREF_LOCALE, foundPlatformLocale);
      AppPreference.setLanguage(foundPlatformLocale);
    }
    AppPreference.setLanguage(language?.toString() ?? DEFAULT_LANGUAGE);
    await EasyLocalization.ensureInitialized();
  }

  static Future<void> saveLocale(Locale? locale) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(PREF_LOCALE, locale.toString());
    EasyLocalization.logger('Locale $locale saved');
  }

  static Widget localizedApp(Widget app) {
    const defaultLoader = CodegenLoader();
    var locales = CodegenLoader.mapLocales.keys
        .map((locale) => Locale(locale))
        .toList();
    return EasyLocalization(
      supportedLocales: locales,
      path: DIRECTORY,
      assetLoader: defaultLoader,
      fallbackLocale: Locale(DEFAULT_LANGUAGE),
      startLocale: Locale(DEFAULT_LANGUAGE),
      useOnlyLangCode: true,
      child: app,
    );
  }

  static String getTitle(Locale? locale) {
    final map = {"en": "English", "en_US": "English", "uk": "Українська"};
    return map[(locale?.languageCode).orValue(map.keys.first)].orEmpty();
  }

  static Future<String> _findSystemLocale() {
    try {
      Intl.systemLocale = Intl.canonicalizedLocale(Platform.localeName);
    } catch (e) {
      return Future.value(Intl.systemLocale);
    }
    return Future.value(Intl.systemLocale);
  }
}

import 'package:flutter/widgets.dart';

import '../storage/app_prefs.dart';
import 'app_language.dart';

/// The language in use right now, without a BuildContext: the choice in
/// [AppPrefs] plus the phone's language. EasyLocalization starts with it,
/// and every API request carries it as `Accept-Language`, so the server
/// answers (errors, notifications, documents) in the same language.
class AppLocale {
  AppLocale(this._prefs, {String Function()? deviceLanguageCode})
    : _deviceLanguageCode =
          deviceLanguageCode ??
          (() =>
              WidgetsBinding.instance.platformDispatcher.locale.languageCode);

  final AppPrefs _prefs;
  final String Function() _deviceLanguageCode;

  String get languageCode =>
      resolveLanguageCode(_prefs.language, _deviceLanguageCode());

  Locale get locale => Locale(languageCode);

  static const supportedLocales = [Locale('uk'), Locale('en')];
}

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';

/// Non-secret flags kept between launches. Notifies listeners on change,
/// so the router can re-run its redirect.
class AppPrefs extends ChangeNotifier {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingSeenKey = 'onboarding_seen';
  static const _launchedBeforeKey = 'launched_before';
  static const _reduceMotionKey = 'reduce_motion';
  static const _languageKey = 'language';
  static const _themeModeKey = 'theme_mode';
  static const _soundsKey = 'sounds';
  static const _paidOrdersKey = 'paid_orders';
  static const _notificationNudgesKey = 'notification_nudges_dismissed';

  bool get onboardingSeen => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_onboardingSeenKey, true);
    notifyListeners();
  }

  /// False on the very first launch after an install.
  bool get launchedBefore => _prefs.getBool(_launchedBeforeKey) ?? false;

  Future<void> setLaunchedBefore() => _prefs.setBool(_launchedBeforeKey, true);

  /// «Звуки в застосунку»: the success sound (the phone's silent mode mutes
  /// it anyway).
  bool get sounds => _prefs.getBool(_soundsKey) ?? true;

  Future<void> setSounds(bool value) async {
    await _prefs.setBool(_soundsKey, value);
    notifyListeners();
  }

  /// Orders paid on this phone, for the «turn notifications on» card.
  int get paidOrders => _prefs.getInt(_paidOrdersKey) ?? 0;

  Future<void> countPaidOrder() => _prefs.setInt(_paidOrdersKey, paidOrders + 1);

  /// How many times «Не треба» was tapped on that card.
  int get notificationNudgesDismissed =>
      _prefs.getInt(_notificationNudgesKey) ?? 0;

  Future<void> dismissNotificationNudge() =>
      _prefs.setInt(_notificationNudgesKey, notificationNudgesDismissed + 1);

  /// «Вимкнути анімації» in the app's settings, on top of the system one.
  bool get reduceMotion => _prefs.getBool(_reduceMotionKey) ?? false;

  Future<void> setReduceMotion(bool value) async {
    await _prefs.setBool(_reduceMotionKey, value);
    notifyListeners();
  }

  /// «Мова» in the app's settings; [AppLanguage.system] until changed.
  AppLanguage get language => AppLanguage.parse(_prefs.getString(_languageKey));

  Future<void> setLanguage(AppLanguage value) async {
    await _prefs.setString(_languageKey, value.name);
    notifyListeners();
  }

  /// «Тема» in the app's settings; [ThemeMode.system] until changed.
  ThemeMode get themeMode =>
      ThemeMode.values.asNameMap()[_prefs.getString(_themeModeKey)] ??
      ThemeMode.system;

  Future<void> setThemeMode(ThemeMode value) async {
    await _prefs.setString(_themeModeKey, value.name);
    notifyListeners();
  }
}

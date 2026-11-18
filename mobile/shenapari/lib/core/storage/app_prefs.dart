import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-secret flags kept between launches. Notifies listeners on change,
/// so the router can re-run its redirect.
class AppPrefs extends ChangeNotifier {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingSeenKey = 'onboarding_seen';
  static const _launchedBeforeKey = 'launched_before';
  static const _reduceMotionKey = 'reduce_motion';

  bool get onboardingSeen => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_onboardingSeenKey, true);
    notifyListeners();
  }

  /// False on the very first launch after an install.
  bool get launchedBefore => _prefs.getBool(_launchedBeforeKey) ?? false;

  Future<void> setLaunchedBefore() => _prefs.setBool(_launchedBeforeKey, true);

  /// «Вимкнути анімації» in the app's settings, on top of the system one.
  bool get reduceMotion => _prefs.getBool(_reduceMotionKey) ?? false;

  Future<void> setReduceMotion(bool value) async {
    await _prefs.setBool(_reduceMotionKey, value);
    notifyListeners();
  }
}

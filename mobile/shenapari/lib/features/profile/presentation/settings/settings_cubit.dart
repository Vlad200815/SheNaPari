import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

import 'package:shenapari_core/l10n/app_language.dart';
import 'package:shenapari_core/l10n/app_locale.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/storage/app_prefs.dart';
import '../../domain/profile_repository.dart';
import '../../../../core/device/notification_permission.dart';

part 'settings_cubit.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    /// From the server; null until loaded (the switch is then disabled).
    bool? orderPush,
    @Default(false) bool reduceMotion,
    @Default(true) bool sounds,

    /// What the phone allows; null until checked.
    NotificationAccess? notifications,
    @Default(AppLanguage.system) AppLanguage language,
    @Default(ThemeMode.system) ThemeMode themeMode,

    /// The language the app shows for [language] (`uk` or `en`); the page
    /// switches the texts to it.
    required String languageCode,
    Failure? failure,
  }) = _SettingsState;
}

/// The switches on «Налаштування». They apply at once, no «Save»: the
/// animation and language ones are stored on the phone, the push one on the
/// server (shown switched right away and switched back if the server
/// refuses).
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._profile, this._prefs, this._locale, this._permission)
    : super(
        SettingsState(
          reduceMotion: _prefs.reduceMotion,
          sounds: _prefs.sounds,
          language: _prefs.language,
          themeMode: _prefs.themeMode,
          languageCode: _locale.languageCode,
        ),
      );

  final ProfileRepository _profile;
  final AppPrefs _prefs;
  final AppLocale _locale;
  final NotificationPermission _permission;

  /// Also when coming back from the phone's settings.
  Future<void> checkNotifications() async {
    if (!_permission.canAsk) return;
    final access = await _permission.status();
    if (!isClosed) emit(state.copyWith(notifications: access));
  }

  /// The «Дозвіл» row: the system dialog while it can still be shown,
  /// otherwise the app's page in the phone's settings.
  Future<void> fixNotifications() async {
    if (state.notifications == NotificationAccess.denied) {
      final access = await _permission.request();
      if (!isClosed) emit(state.copyWith(notifications: access));
      return;
    }
    await _permission.openSettings();
  }

  Future<void> setSounds(bool value) async {
    emit(state.copyWith(sounds: value));
    await _prefs.setSounds(value);
  }

  Future<void> load() async {
    await checkNotifications();
    if (await _profile.getMe() case Ok(:final value)) {
      emit(state.copyWith(orderPush: value.orderPushEnabled ?? true));
    }
  }

  Future<void> setOrderPush(bool enabled) async {
    final before = state.orderPush;
    if (before == null || before == enabled) return;
    emit(state.copyWith(orderPush: enabled, failure: null));
    if (await _profile.setOrderPush(enabled: enabled) case Err(
      :final failure,
    )) {
      emit(state.copyWith(orderPush: before, failure: failure));
    }
  }

  Future<void> setReduceMotion(bool value) async {
    emit(state.copyWith(reduceMotion: value));
    await _prefs.setReduceMotion(value);
  }

  Future<void> setLanguage(AppLanguage value) async {
    await _prefs.setLanguage(value);
    emit(state.copyWith(language: value, languageCode: _locale.languageCode));
  }

  /// The app follows AppPrefs, so the whole app turns at once.
  Future<void> setThemeMode(ThemeMode value) async {
    emit(state.copyWith(themeMode: value));
    await _prefs.setThemeMode(value);
  }
}

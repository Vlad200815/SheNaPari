import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../domain/profile_repository.dart';

part 'settings_cubit.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    /// From the server; null until loaded (the switch is then disabled).
    bool? orderPush,
    @Default(false) bool reduceMotion,
    Failure? failure,
  }) = _SettingsState;
}

/// The switches on «Налаштування». They apply at once, no «Save»: the
/// animation one is stored on the phone, the push one on the server (shown
/// switched right away and switched back if the server refuses).
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._profile, this._prefs)
    : super(SettingsState(reduceMotion: _prefs.reduceMotion));

  final ProfileRepository _profile;
  final AppPrefs _prefs;

  Future<void> load() async {
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
}

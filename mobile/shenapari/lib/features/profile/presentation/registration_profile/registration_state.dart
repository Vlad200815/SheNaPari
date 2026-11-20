import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';

part 'registration_state.freezed.dart';

/// `saved` keeps the button busy until the router leaves the screen.
enum RegistrationStatus { editing, saving, saved, failure }

@freezed
abstract class RegistrationState with _$RegistrationState {
  const RegistrationState._();

  const factory RegistrationState({
    @Default('') String name,
    @Default(RegistrationStatus.editing) RegistrationStatus status,
    Failure? failure,
  }) = _RegistrationState;

  /// The server requires 2–100 characters; the button stays off until then.
  bool get canSubmit => name.trim().length >= 2;

  bool get isBusy =>
      status == RegistrationStatus.saving || status == RegistrationStatus.saved;
}

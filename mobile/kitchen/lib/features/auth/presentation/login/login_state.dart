import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenapari_core/result/failure.dart';

part 'login_state.freezed.dart';

enum LoginStatus { editing, sending, failure }

@freezed
abstract class LoginState with _$LoginState {
  const LoginState._();

  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    @Default(LoginStatus.editing) LoginStatus status,
    Failure? failure,
  }) = _LoginState;

  /// Enough to try: something@something and a password. The server says
  /// whether they match.
  bool get canSubmit =>
      RegExp(r'^\S+@\S+$').hasMatch(email.trim()) && password.isNotEmpty;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';

part 'code_state.freezed.dart';

/// `success` keeps the button busy until the router leaves the screen.
enum CodeStatus { idle, verifying, resending, success, failure }

@freezed
abstract class CodeState with _$CodeState {
  const CodeState._();

  const factory CodeState({
    @Default(CodeStatus.idle) CodeStatus status,

    /// Seconds until a new code may be requested; 0 means "now".
    @Default(0) int resendIn,
    Failure? failure,
  }) = _CodeState;

  bool get isBusy =>
      status == CodeStatus.verifying ||
      status == CodeStatus.resending ||
      status == CodeStatus.success;
}

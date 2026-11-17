import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/auth_repository.dart';
import '../../domain/usecases/verify_code.dart';
import 'code_state.dart';

/// Emits the seconds left: `seconds - 1, ..., 0`, one per second.
/// Injected so tests do not wait for real time.
typedef Countdown = Stream<int> Function(int seconds);

Stream<int> secondsCountdown(int seconds) => Stream.periodic(
  const Duration(seconds: 1),
  (tick) => seconds - tick - 1,
).take(seconds);

class CodeCubit extends Cubit<CodeState> {
  CodeCubit(
    this._verifyCode,
    this._auth, {
    required this.phone,
    Countdown countdown = secondsCountdown,
  }) : _countdown = countdown,
       super(const CodeState(resendIn: resendDelay)) {
    _startCountdown();
  }

  /// The server lets a new code be sent once per 60 seconds.
  static const resendDelay = 60;
  static const codeLength = 6;

  /// The number the code was sent to; fixed for the screen's lifetime.
  final String phone;

  final VerifyCode _verifyCode;
  final AuthRepository _auth;
  final Countdown _countdown;
  StreamSubscription<int>? _ticker;

  Future<void> verify(String code) async {
    if (code.length != codeLength || state.isBusy) return;
    emit(state.copyWith(status: CodeStatus.verifying, failure: null));

    switch (await _verifyCode(phone: phone, code: code)) {
      case Ok():
        // The session is saved; the router leaves this screen by itself.
        emit(state.copyWith(status: CodeStatus.success));
      case Err(:final failure):
        emit(state.copyWith(status: CodeStatus.failure, failure: failure));
    }
  }

  Future<void> resend() async {
    if (state.resendIn > 0 || state.isBusy) return;
    emit(state.copyWith(status: CodeStatus.resending, failure: null));

    switch (await _auth.requestCode(phone: phone)) {
      case Ok():
        emit(state.copyWith(status: CodeStatus.idle, resendIn: resendDelay));
        _startCountdown();
      case Err(:final failure):
        emit(state.copyWith(status: CodeStatus.failure, failure: failure));
    }
  }

  void _startCountdown() {
    _ticker?.cancel();
    _ticker = _countdown(
      resendDelay,
    ).listen((left) => emit(state.copyWith(resendIn: left)));
  }

  @override
  Future<void> close() async {
    await _ticker?.cancel();
    return super.close();
  }
}

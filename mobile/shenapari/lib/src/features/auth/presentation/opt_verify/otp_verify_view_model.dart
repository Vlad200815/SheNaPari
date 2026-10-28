import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';
import 'package:shenapari/src/core/servies/fcm_service.dart';
import 'package:shenapari/src/core/servies/uk_phone_number_formater.dart';
import 'package:shenapari/src/features/auth/domain/entities/auth.dart';
import 'package:shenapari/src/features/auth/domain/usecases/auth.dart';

import 'otp_verify_action.dart';
import 'otp_verify_event.dart';
import 'otp_verify_state.dart';

class OtpVerifyViewModel
    extends BaseViewModel<OtpVerifyState, OtpVerifyEvent, OtpVerifyAction> {
  final ResendOtpCodeUseCase _resendOtpCodeUseCase;
  final VerifyOtpCodeUseCase _verifyOtpCodeUseCase;

  final int otpCodeExpiresInSeconds;
  String phoneNumber;

  bool _isEnabledResend = false;
  String? _resendTimeLeft;

  OtpVerifyViewModel({
    required this.otpCodeExpiresInSeconds,
    required this.phoneNumber,
    required ResendOtpCodeUseCase resendOtpCodeUseCase,
    required VerifyOtpCodeUseCase verifyOtpCodeUseCase,
  }) : _verifyOtpCodeUseCase = verifyOtpCodeUseCase,
       _resendOtpCodeUseCase = resendOtpCodeUseCase,
       super(OtpVerifyState()) {
    phoneNumber = ukrainianPhoneNumberFormater(rawPhoneNumber: phoneNumber);
  }

  @override
  Future<void> onViewCreate(
    Emitter<OtpVerifyState> emitter,
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) async {
    await _startTimer(emitter);
  }

  @override
  Future<void> onViewAction(
    OtpVerifyAction action,
    Emitter<OtpVerifyState> emitter,
  ) async {
    switch (action) {
      case OnEditButtonPressedAction action:
        await _handleOnEditButtonPressedAction(action, emitter);

      case OnResendButtonPressedAction action:
        await _handleOnResendButtonPressedAction(action, emitter);

      case OnVerifyButtonPressedAction action:
        await _handleOnVerifyButtonPressedAction(action, emitter);
    }
  }

  ///
  /// Handle [OnVerifyButtonPressedAction]
  ///
  Future<void> _handleOnVerifyButtonPressedAction(
    OnVerifyButtonPressedAction action,
    Emitter<OtpVerifyState> emitter,
  ) async {
    loading(true);
    try {
      String? cachedToken = await AppPreference.fcmToken;
      debugPrint("cachedToken: $cachedToken");

      if (cachedToken.isNullOrEmpty()) {
        cachedToken = await FCMService().getFCMToken();
      }

      final String fcmToken = cachedToken ?? Config.EMPTY_FALLBACK;

      final String userOtpCode = action.pinPutController.text;
      debugPrint("userOtpCode: ${userOtpCode.runtimeType}");

      final Result<JWTEntity> result = await _verifyOtpCodeUseCase.perform(
        phoneNumber,
        userOtpCode,
        fcmToken,
      );

      if (result.succeeded.orFalse()) {
        // Save access and refresh tokens
        AppSecureStorage.saveTokens(
          accessToken: (result.data?.accessToken).orEmpty(),
          refreshToken: (result.data?.refreshToken).orEmpty(),
        );
        if ((result.data?.isNewUser).orFalse()) {
          postEvent(OpenRegistrationProfilePageEvent(), emitter);
        } else {
          // User is successfully authenticated
          await AppPreference.setAuthenticated(true);
          authNotifier.value = true;
          // Go to Home Page
          postEvent(OpenHomePageEvent(), emitter);
        }
      } else {
        message(result.message.orEmpty());
      }
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }

  ///
  /// Handle [OnResendButtonPressedAction]
  ///
  Future<void> _handleOnResendButtonPressedAction(
    OnResendButtonPressedAction action,
    Emitter<OtpVerifyState> emitter,
  ) async {
    loading(true);
    try {
      await _resendOtpCodeUseCase.perform(phoneNumber);
      action.pinPutController.clear();

      loading(false);
      await _startTimer(emitter);
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }

  ///
  /// Handle [OnEditButtonPressedAction]
  ///
  Future<void> _handleOnEditButtonPressedAction(
    OnEditButtonPressedAction action,
    Emitter<OtpVerifyState> emitter,
  ) async {
    _isEnabledResend = false;
    _updateState(emitter);
    postEvent(PopOtpVerifyPageEvent(), emitter);
  }

  /// Start Timer
  Future<void> _startTimer(Emitter<OtpVerifyState> emitter) async {
    await emitter.forEach<int>(
      _createTimerStream(),
      onData: (timeLeft) {
        if (timeLeft > 0) {
          _isEnabledResend = false;
          _resendTimeLeft = _formatTime(timeLeft);
        } else {
          _isEnabledResend = true;
          _resendTimeLeft = "00:00";
        }

        // This returns the new state copied with your modified variables
        return state.copyWith(
          resendTimeLeft: _resendTimeLeft,
          isEnabledResend: _isEnabledResend,
        );
      },
    );
  }

  /// Creates a stream that counts down from your initial seconds to 0
  Stream<int> _createTimerStream() {
    return Stream.periodic(const Duration(seconds: 1), (computationCount) {
      return otpCodeExpiresInSeconds - computationCount - 1;
    }).take(
      otpCodeExpiresInSeconds + 1,
    ); // Automatically stops the stream when it hits 0
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  ///Update State
  void _updateState(Emitter<OtpVerifyState> emitter) {
    emitter(
      state.copyWith(
        resendTimeLeft: _resendTimeLeft,
        isEnabledResend: _isEnabledResend,
      ),
    );
  }
}

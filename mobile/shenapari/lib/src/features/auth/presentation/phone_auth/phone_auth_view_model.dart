import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/servies/uk_phone_number_formater.dart';
import 'package:shenapari/src/features/auth/domain/entities/auth.dart';
import 'package:shenapari/src/features/auth/domain/usecases/auth.dart';

import 'phone_auth_action.dart';
import 'phone_auth_event.dart';
import 'phone_auth_state.dart';

class PhoneAuthViewModel
    extends BaseViewModel<PhoneAuthState, PhoneAuthEvent, PhoneAuthAction> {
  final SendOtpCodeUseCase _sendOtpCodeUseCase;

  PhoneAuthViewModel({required SendOtpCodeUseCase sendOtpCodeUseCase})
    : _sendOtpCodeUseCase = sendOtpCodeUseCase,
      super(PhoneAuthState());

  bool _isEnabledContinueButton = false;

  @override
  Future<void> onViewAction(
    PhoneAuthAction action,
    Emitter<PhoneAuthState> emitter,
  ) async {
    switch (action) {
      case OnContinueButtonPressedAction action:
        await _handleOnContinueButtonPressedAction(action, emitter);

      case OnClearInputButtonPressedAction action:
        await _handleOnClearInputButtonPressedAction(action, emitter);

      case OnInputFormChangedAction action:
        await _handleOnInputFormChangedAction(action, emitter);

      case OnTermsOfUseHyperTextPressedAction action:
        await _handleOnTermsOfUseHyperTextPressedAction(action, emitter);

      case OnPrivacyPolicyHyperTextPressedAction action:
        await _handleOnPrivacyPolicyHyperTextPressedAction(action, emitter);

      case TestLoaderAction action:
        await _handleTestLoaderAction(action, emitter);
    }
  }

  /// Test loader
  Future<void> _handleTestLoaderAction(
    TestLoaderAction action,
    Emitter<PhoneAuthState> emitter,
  ) async {
    loading(true);
  }

  ///
  /// Handle [OnContinueButtonPressedAction]
  ///
  Future<void> _handleOnContinueButtonPressedAction(
    OnContinueButtonPressedAction action,
    Emitter<PhoneAuthState> emitter,
  ) async {
    loading(true);
    try {
      debugPrint("Phone Number Before replace: ${action.phoneNumber}");
      final String phoneNumber = ukrainianPhoneNumberFormater(
        rawPhoneNumber: action.phoneNumber,
      );
      debugPrint("Phone Number After replace: $phoneNumber");

      final Result<OtpEntity> otpData = await _sendOtpCodeUseCase.perform(
        phoneNumber,
      );

      if (otpData.succeeded.orFalse()) {
        final int otpCodeExpiresInSeconds = (otpData.data?.expiresInSeconds)
            .orZero();

        debugPrint("Opt code: ${otpData.data?.debugOtp}");

        postEvent(
          OpenOtpVerifyPageEvent(
            otpCodeExpiresInSeconds: otpCodeExpiresInSeconds,
          ),
          emitter,
        );
      } else {
        message(otpData.message.orEmpty());
      }
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }

  ///
  /// Handle [OnInputFormChangedAction]
  ///
  Future<void> _handleOnInputFormChangedAction(
    OnInputFormChangedAction action,
    Emitter<PhoneAuthState> emitter,
  ) async {
    if (!action.phoneNumber.isNullOrEmpty()) {
      if (action.phoneNumber?.replaceAll(" ", "").length == 9) {
        _isEnabledContinueButton = true;
        debugPrint("Continue is enabled");
      } else {
        _isEnabledContinueButton = false;
      }
      _updateState(emitter);
    }
  }

  ///
  /// Handle [OnClearInputButtonPressedAction]
  ///
  Future<void> _handleOnClearInputButtonPressedAction(
    OnClearInputButtonPressedAction action,
    Emitter<PhoneAuthState> emitter,
  ) async {
    action.phoneNumberController.clear();
    _isEnabledContinueButton = false;
    _updateState(emitter);
  }

  ///
  /// Handle [OnTermsOfUseHyperTextPressedAction]
  ///
  Future<void> _handleOnTermsOfUseHyperTextPressedAction(
    OnTermsOfUseHyperTextPressedAction action,
    Emitter<PhoneAuthState> emitter,
  ) async => postEvent(OpenTermsOfUsePageEvent(), emitter);

  ///
  /// Handle [OnPrivacyPolicyHyperTextPressedAction]
  ///
  Future<void> _handleOnPrivacyPolicyHyperTextPressedAction(
    OnPrivacyPolicyHyperTextPressedAction action,
    Emitter<PhoneAuthState> emitter,
  ) async => postEvent(OpenPrivacyPolicyPageEvent(), emitter);

  ///Update State
  void _updateState(Emitter<PhoneAuthState> emitter) {
    emitter(state.copyWith(isEnabledContinueButton: _isEnabledContinueButton));
  }
}

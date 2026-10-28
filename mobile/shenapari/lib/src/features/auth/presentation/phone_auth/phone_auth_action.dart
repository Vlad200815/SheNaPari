import 'package:flutter/cupertino.dart';
import 'package:shenapari/src/core/base/base_view_action.dart';

sealed class PhoneAuthAction extends ViewAction {}

final class OnContinueButtonPressedAction extends PhoneAuthAction {
  final String phoneNumber;

  OnContinueButtonPressedAction({required this.phoneNumber});
}

final class OnClearInputButtonPressedAction extends PhoneAuthAction {
  final TextEditingController phoneNumberController;

  OnClearInputButtonPressedAction({required this.phoneNumberController});
}

final class OnInputFormChangedAction extends PhoneAuthAction {
  final String? phoneNumber;

  OnInputFormChangedAction({required this.phoneNumber});
}

final class OnTermsOfUseHyperTextPressedAction extends PhoneAuthAction {}

final class OnPrivacyPolicyHyperTextPressedAction extends PhoneAuthAction {}

final class TestLoaderAction extends PhoneAuthAction {}

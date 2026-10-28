import 'package:flutter/cupertino.dart';
import 'package:shenapari/src/core/base/base_view_action.dart';

sealed class OtpVerifyAction extends ViewAction {}

final class OnEditButtonPressedAction extends OtpVerifyAction {}

final class OnResendButtonPressedAction extends OtpVerifyAction {
  final TextEditingController pinPutController;

  OnResendButtonPressedAction({required this.pinPutController});
}

final class OnVerifyButtonPressedAction extends OtpVerifyAction {
  final TextEditingController pinPutController;

  OnVerifyButtonPressedAction({required this.pinPutController});
}

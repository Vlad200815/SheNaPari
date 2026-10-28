import 'package:shenapari/src/core/base/base_view_event.dart';

sealed class PhoneAuthEvent extends ViewEvent {}

final class OpenTermsOfUsePageEvent extends PhoneAuthEvent {}

final class OpenPrivacyPolicyPageEvent extends PhoneAuthEvent {}

final class OpenOtpVerifyPageEvent extends PhoneAuthEvent {
  final int otpCodeExpiresInSeconds;

  OpenOtpVerifyPageEvent({required this.otpCodeExpiresInSeconds});
}

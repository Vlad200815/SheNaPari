import 'package:shenapari/src/core/base/base_view_event.dart';

sealed class OtpVerifyEvent extends ViewEvent {}

final class PopOtpVerifyPageEvent extends OtpVerifyEvent {}

final class OpenHomePageEvent extends OtpVerifyEvent {}

final class OpenRegistrationProfilePageEvent extends OtpVerifyEvent {}

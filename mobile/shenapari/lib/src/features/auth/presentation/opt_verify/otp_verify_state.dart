import 'package:shenapari/src/core/base/base_view_state.dart';

final class OtpVerifyState extends ViewState {
  final bool? isEnabledResend;
  final String? resendTimeLeft;

  OtpVerifyState({this.isEnabledResend = false, this.resendTimeLeft});

  OtpVerifyState copyWith({bool? isEnabledResend, String? resendTimeLeft}) {
    return OtpVerifyState(
      isEnabledResend: isEnabledResend ?? this.isEnabledResend,
      resendTimeLeft: resendTimeLeft ?? this.resendTimeLeft,
    );
  }

  @override
  List<Object?> get props => [isEnabledResend, resendTimeLeft];
}

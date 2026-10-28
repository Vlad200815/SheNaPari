import 'package:shenapari/src/core/base/base_view_state.dart';

final class PhoneAuthState extends ViewState {
  final bool? isEnabledContinueButton;

  PhoneAuthState({this.isEnabledContinueButton = false});

  PhoneAuthState copyWith({bool? isEnabledContinueButton}) {
    return PhoneAuthState(
      isEnabledContinueButton:
          isEnabledContinueButton ?? this.isEnabledContinueButton,
    );
  }

  @override
  List<Object?> get props => [isEnabledContinueButton];
}

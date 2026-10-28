import 'package:shenapari/src/core/base/base_view_state.dart';

final class OnboardingState extends ViewState {
  final int? selectedPage;

  OnboardingState({this.selectedPage});

  OnboardingState copyWith({int? selectedPage}) {
    return OnboardingState(selectedPage: selectedPage ?? this.selectedPage);
  }

  @override
  List<Object?> get props => [selectedPage];
}

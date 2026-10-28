import 'package:flutter/cupertino.dart';
import 'package:shenapari/src/core/base/base_view_action.dart';

sealed class OnboardingAction extends ViewAction {}

final class OnNextButtonPressedAction extends OnboardingAction {
  final PageController? pageController;

  OnNextButtonPressedAction({required this.pageController});
}

final class OnSkipButtonPressedAction extends OnboardingAction {}

final class OnPageChangedAction extends OnboardingAction {
  final int selectedPage;

  OnPageChangedAction({required this.selectedPage});
}

final class OnStartButtonPressedAction extends OnboardingAction {}

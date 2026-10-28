import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';
import 'package:shenapari/src/features/info/presentation/onboarding/onboarding_action.dart';

import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingViewModel
    extends BaseViewModel<OnboardingState, OnboardingEvent, OnboardingAction> {
  int _selectedPage = 0;

  OnboardingViewModel() : super(OnboardingState());

  @override
  Future<void> onViewAction(
    OnboardingAction action,
    Emitter<OnboardingState> emitter,
  ) async {
    switch (action) {
      case OnNextButtonPressedAction action:
        await _handleOnNextButtonPressedAction(action, emitter);

      case OnSkipButtonPressedAction action:
        await _handleOnSkipButtonPressedAction(action, emitter);

      case OnPageChangedAction action:
        await _handleOnPageChangedAction(action, emitter);

      case OnStartButtonPressedAction action:
        await _handleOnStartButtonPressedAction(action, emitter);
    }
  }

  ///
  /// Handle [OnNextButtonPressedAction]
  ///
  Future<void> _handleOnNextButtonPressedAction(
    OnNextButtonPressedAction action,
    Emitter<OnboardingState> emitter,
  ) async {
    action.pageController?.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.ease,
    );
  }

  ///
  /// Handle [OnSkipButtonPressedAction]
  ///
  Future<void> _handleOnSkipButtonPressedAction(
    OnSkipButtonPressedAction action,
    Emitter<OnboardingState> emitter,
  ) async => _openPhoneAuthPage(emitter);

  ///
  /// Handle [OnPageChangedAction]
  ///
  Future<void> _handleOnPageChangedAction(
    OnPageChangedAction action,
    Emitter<OnboardingState> emitter,
  ) async {
    _selectedPage = action.selectedPage;
    _updateState(emitter);
  }

  ///
  /// Handle [OnStartButtonPressedAction]
  ///
  Future<void> _handleOnStartButtonPressedAction(
    OnStartButtonPressedAction action,
    Emitter<OnboardingState> emitter,
  ) async {
    // Request permission
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      // Everything is fine, proceed to the app
      _openPhoneAuthPage(emitter);
    } else {
      // Request native permission dialog
      await Permission.notification.request();
      _openPhoneAuthPage(emitter);
    }
  }

  /// OpenPhoneAuthPage
  void _openPhoneAuthPage(Emitter<OnboardingState> emitter) {
    AppPreference.setShowedIntro(true);
    introNotifier.value = true;

    postEvent(OpenPhoneAuthPageEvent(), emitter);
  }

  ///Update State
  void _updateState(Emitter<OnboardingState> emitter) {
    emitter(state.copyWith(selectedPage: _selectedPage));
  }
}

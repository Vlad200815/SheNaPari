import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';

import 'registration_success_action.dart';
import 'registration_success_event.dart';
import 'registration_success_state.dart';

class RegistrationSuccessViewModel
    extends
        BaseViewModel<
          RegistrationSuccessState,
          RegistrationSuccessEvent,
          RegistrationSuccessAction
        > {
  RegistrationSuccessViewModel() : super(RegistrationSuccessState());

  @override
  Future<void> onViewAction(
    RegistrationSuccessAction action,
    Emitter<RegistrationSuccessState> emitter,
  ) async {
    switch (action) {
      case OnGotItButtonPressedAction action:
        await _handleOnGotItButtonPressedAction(action, emitter);
    }
  }

  ///
  /// Handle [OnGotItButtonPressedAction]
  ///
  Future<void> _handleOnGotItButtonPressedAction(
    OnGotItButtonPressedAction action,
    Emitter<RegistrationSuccessState> emitter,
  ) async {
    loading(true);
    try {
      await AppPreference.setAuthenticated(true);
      authNotifier.value = true;
      debugPrint("Registration for a new user went successfully");
      postEvent(OpenHomePageEvent(), emitter);
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }
}

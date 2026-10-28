import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';

import 'profile_action.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileViewModel
    extends BaseViewModel<ProfileState, ProfileEvent, ProfileAction> {
  ProfileViewModel() : super(ProfileState());

  @override
  Future<void> onViewAction(
    ProfileAction action,
    Emitter<ProfileState> emitter,
  ) async {
    switch (action) {
      case OnLogOutButtonPressedAction action:
        await _handleOnLogOutButtonPressedAction(action, emitter);
    }
  }

  ///
  /// Handle [OnLogOutButtonPressedAction]
  ///
  Future<void> _handleOnLogOutButtonPressedAction(
    OnLogOutButtonPressedAction action,
    Emitter<ProfileState> emitter,
  ) async {
    loading(true);
    try {
      //TODO: This is mocked log out logic
      await AppSecureStorage.deleteTokens();
      await AppPreference.setAuthenticated(false);
      authNotifier.value = false;

      debugPrint("Mock Log Out");
    } catch (e) {
      setThrowable(e);
      loading(false);
    }
  }
}

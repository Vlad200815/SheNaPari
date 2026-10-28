import 'package:shenapari/src/core/base/base_view_model.dart';

import 'registration_profile_action.dart';
import 'registration_profile_event.dart';
import 'registration_profile_state.dart';

class RegistrationProfileViewModel
    extends
        BaseViewModel<
          RegistrationProfileState,
          RegistrationProfileEvent,
          RegistrationProfileAction
        > {
  RegistrationProfileViewModel() : super(RegistrationProfileState());
}

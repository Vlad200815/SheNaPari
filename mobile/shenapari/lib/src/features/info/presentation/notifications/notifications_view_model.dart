import 'package:shenapari/src/core/base/base_view_model.dart';

import 'notifications_action.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsViewModel
    extends
        BaseViewModel<
          NotificationsState,
          NotificationsEvent,
          NotificationsAction
        > {
  NotificationsViewModel() : super(NotificationsState());
}

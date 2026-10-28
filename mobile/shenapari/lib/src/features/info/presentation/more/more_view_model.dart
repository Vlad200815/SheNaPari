import 'package:shenapari/src/core/base/base_view_model.dart';

import 'more_action.dart';
import 'more_event.dart';
import 'more_state.dart';

class MoreViewModel extends BaseViewModel<MoreState, MoreEvent, MoreAction> {
  MoreViewModel() : super(MoreState());
}

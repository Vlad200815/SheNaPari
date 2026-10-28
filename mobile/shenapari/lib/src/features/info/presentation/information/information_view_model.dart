import 'package:shenapari/src/core/base/base_view_model.dart';

import 'information_action.dart';
import 'information_event.dart';
import 'information_state.dart';

class InformationViewModel
    extends
        BaseViewModel<InformationState, InformationEvent, InformationAction> {
  InformationViewModel() : super(InformationState());
}

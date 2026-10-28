import 'package:shenapari/src/core/base/base_view_action.dart';

class AppAction extends ViewAction {}

class OnShowedIntroAction extends AppAction {
  final bool isShowed;

  OnShowedIntroAction(this.isShowed);
}

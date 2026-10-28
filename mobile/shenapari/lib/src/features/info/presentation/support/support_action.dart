import 'package:shenapari/src/core/base/base_view_action.dart';

sealed class SupportAction extends ViewAction {}

final class OnTelegramButtonPressedAction extends SupportAction {
  final String? startParameter;

  OnTelegramButtonPressedAction({this.startParameter});
}

final class OnEmailButtonPressedAction extends SupportAction {}

final class OnPhoneButtonPressedAction extends SupportAction {}

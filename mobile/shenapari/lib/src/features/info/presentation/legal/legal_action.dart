import 'package:shenapari/src/core/base/base_view_action.dart';

sealed class LegalAction extends ViewAction {}

final class OnLinkPressedAction extends LegalAction {
  final String? href;

  OnLinkPressedAction({required this.href});
}

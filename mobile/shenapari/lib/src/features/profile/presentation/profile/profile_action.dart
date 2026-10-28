import 'package:shenapari/src/core/base/base_view_action.dart';

sealed class ProfileAction extends ViewAction {}

final class OnLogOutButtonPressedAction extends ProfileAction {}

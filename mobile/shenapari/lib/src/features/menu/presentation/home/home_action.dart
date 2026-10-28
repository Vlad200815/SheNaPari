import 'package:shenapari/src/core/base/base_view_action.dart';

sealed class HomeAction extends ViewAction {}

final class OnRefreshPulledAction extends HomeAction {}

final class OnCategoryChangedAction extends HomeAction {
  final String category;

  OnCategoryChangedAction({required this.category});
}

final class OnNotificationsButtonPressed extends HomeAction {}

final class OnProductTilePressedAction extends HomeAction {
  final String id;

  OnProductTilePressedAction({required this.id});
}

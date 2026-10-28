import 'package:shenapari/src/core/base/base_view_event.dart';

sealed class HomeEvent extends ViewEvent {}

final class OpenNotificationsPageEvent extends HomeEvent {}

final class OpenProductDetailsPageEvent extends HomeEvent {
  final String id;
  final String section;

  OpenProductDetailsPageEvent({required this.id, required this.section});
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../../orders/domain/order_events.dart';
import '../domain/entities/app_notification.dart';
import '../domain/notifications_repository.dart';

part 'notifications_cubit.freezed.dart';

enum NotificationsStatus { loading, loaded, failure }

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(NotificationsStatus.loading) NotificationsStatus status,
    @Default(<AppNotification>[]) List<AppNotification> items,
    Failure? failure,
  }) = _NotificationsState;
}

/// The list under the bell. Opening it marks everything read on the
/// server, but the items keep their `isRead` from the load, so the new
/// ones stay highlighted while the screen is open.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._notifications, this._events)
    : super(const NotificationsState());

  final NotificationsRepository _notifications;
  final OrderEvents _events;
  StreamSubscription<String?>? _live;

  Future<void> load() async {
    await _fetch();
    // An order changed → maybe a new notification.
    _live ??= _events.changes.listen((_) => _fetch());
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    switch (await _notifications.getAll()) {
      case Ok(value: final items):
        emit(state.copyWith(status: NotificationsStatus.loaded, items: items));
        if (items.any((n) => !n.isRead)) await _notifications.markAllRead();
      case Err(:final failure):
        emit(
          state.copyWith(
            status: state.status == NotificationsStatus.loaded
                ? NotificationsStatus.loaded
                : NotificationsStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _live?.cancel();
    return super.close();
  }
}

/// The orange dot on the bell: are there unread notifications?
class UnreadNotificationsCubit extends Cubit<bool> {
  UnreadNotificationsCubit(this._notifications, this._events) : super(false);

  final NotificationsRepository _notifications;
  final OrderEvents _events;
  StreamSubscription<String?>? _live;

  Future<void> load() async {
    if (await _notifications.getAll() case Ok(value: final items)) {
      emit(items.any((n) => !n.isRead));
    }
    _live ??= _events.changes.listen((_) => load());
  }

  /// The list was opened: everything is read now.
  void markSeen() => emit(false);

  @override
  Future<void> close() async {
    await _live?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:shenapari_core/session/session_repository.dart';
import 'package:shenapari_core/session/session_status.dart';

import '../../../app/router/routes.dart';
import '../../../core/device/push_messages.dart';
import '../domain/push_repository.dart';

/// Glue between the phone's pushes and the app: once signed in it sends
/// the device token (again when Firebase changes it), and a tapped push
/// opens its order — «Як вам №36?» with the rating sheet. A tap that comes
/// before the session is known (the app launched from a push) waits for it.
class PushCoordinator {
  PushCoordinator(this._messages, this._repository, this._session);

  final PushMessages _messages;
  final PushRepository _repository;
  final SessionRepository _session;
  final _subscriptions = <StreamSubscription<Object?>>[];
  void Function(String location)? _open;
  PushTap? _waiting;

  bool get _signedIn => _session.status == SessionStatus.authenticated;

  /// [open] shows a location over the current screen (`router.push`).
  Future<void> start({required void Function(String location) open}) async {
    _open = open;
    await _messages.init();
    _subscriptions
      ..add(_session.statusChanges.listen((_) => _onSession()))
      ..add(_messages.tokenRefresh.listen(_send))
      ..add(_messages.taps.listen(_onTap));
    _waiting = await _messages.initialTap();
    await _onSession();
  }

  Future<void> _onSession() async {
    if (!_signedIn) return;
    if (_waiting case final tap?) {
      _waiting = null;
      _show(tap);
    }
    if (await _messages.token() case final token?) await _send(token);
  }

  Future<void> _send(String token) async {
    if (_signedIn) await _repository.register(token);
  }

  void _onTap(PushTap tap) => _signedIn ? _show(tap) : _waiting = tap;

  void _show(PushTap tap) {
    if (location(tap) case final location?) _open?.call(location);
  }

  /// Where a push leads; null: nowhere in particular.
  static String? location(PushTap tap) => switch (tap) {
    PushTap(type: 'rate_order', :final orderId?) => Routes.orderRate(orderId),
    PushTap(:final orderId?) => Routes.order(orderId),
    _ => null,
  };

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }
}

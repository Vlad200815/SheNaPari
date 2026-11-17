import 'dart:async';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../../../core/session/session_repository.dart';
import '../domain/order_events.dart';

/// [OrderEvents] over the backend's SignalR hub `/hubs/orders`.
///
/// The hub puts each connection into the group of its user, so only the
/// customer's own orders arrive. The connection opens when the first screen
/// starts listening and closes when the last one stops (or on sign-out).
///
/// The access token is read at connect time. Screens load orders over REST
/// before listening, and that request refreshes an expired token, so the
/// token here is fresh.
class SignalROrderEvents implements OrderEvents {
  SignalROrderEvents({
    required String baseUrl,
    required SessionRepository session,
  }) : _url = '$baseUrl/hubs/orders',
       _session = session {
    _controller = StreamController<String?>.broadcast(
      onListen: _connect,
      onCancel: _disconnect,
    );
  }

  final String _url;
  final SessionRepository _session;
  late final StreamController<String?> _controller;
  HubConnection? _hub;

  @override
  Stream<String?> get changes => _controller.stream;

  Future<void> _connect() async {
    if (_hub != null) return;
    final hub = HubConnectionBuilder()
        .withUrl(
          _url,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => _session.tokens?.accessToken ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();
    hub
      ..on('OrderStatusChanged', (arguments) {
        final event = arguments?.firstOrNull;
        if (event is Map) _controller.add(event['orderId']?.toString());
      })
      // Events sent while offline are lost: ask screens to reload.
      ..onreconnected(({connectionId}) => _controller.add(null));
    _hub = hub;
    try {
      await hub.start();
    } on Object catch (error) {
      // No live updates then; screens still have pull-to-refresh.
      developer.log('Order updates unavailable', name: 'orders', error: error);
    }
  }

  Future<void> _disconnect() async {
    final hub = _hub;
    _hub = null;
    await hub?.stop();
  }
}

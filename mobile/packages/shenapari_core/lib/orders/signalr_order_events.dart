import 'dart:async';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../session/session_repository.dart';
import 'order_events.dart';

/// [OrderEvents] over the backend's SignalR hub `/hubs/orders`.
///
/// The hub puts each connection into the group of its user, so a customer
/// gets only their own orders; staff are also in the staff group and get
/// every order, new ones included (`OrderCreated`). The connection opens when the first screen
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
  Timer? _retry;

  /// How long to wait before opening a new connection after the old one
  /// gave up (e.g. its token expired). Any REST call in between refreshes
  /// the token the new connection will use.
  static const retryDelay = Duration(seconds: 15);

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
      // Staff only: a new paid order (the payload is the whole order).
      ..on('OrderCreated', (arguments) {
        final event = arguments?.firstOrNull;
        if (event is Map) _controller.add(event['id']?.toString());
      })
      // Events sent while offline are lost: ask screens to reload.
      ..onreconnected(({connectionId}) => _controller.add(null))
      // Automatic reconnect gave up: start over while screens still listen.
      ..onclose(({error}) {
        if (identical(_hub, hub)) _retryLater();
      });
    _hub = hub;
    try {
      await hub.start();
    } on Object catch (error) {
      // Screens still have pull-to-refresh; try again a bit later.
      developer.log('Order updates unavailable', name: 'orders', error: error);
      if (identical(_hub, hub)) _retryLater();
    }
  }

  void _retryLater() {
    _hub = null;
    _retry?.cancel();
    _retry = Timer(retryDelay, () {
      if (_controller.hasListener) {
        _connect();
        _controller.add(null); // whatever happened meanwhile, reload it
      }
    });
  }

  Future<void> _disconnect() async {
    _retry?.cancel();
    final hub = _hub;
    _hub = null;
    await hub?.stop();
  }
}

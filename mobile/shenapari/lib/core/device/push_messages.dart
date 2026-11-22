import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A push the person tapped: what it is about (the backend's `data`).
class PushTap extends Equatable {
  const PushTap({required this.type, this.orderId});

  /// `order_status`, `rate_order`.
  factory PushTap.fromData(Map<String, dynamic> data) => PushTap(
    type: data['type']?.toString() ?? '',
    orderId: data['orderId']?.toString(),
  );

  final String type;
  final String? orderId;

  @override
  List<Object?> get props => [type, orderId];
}

/// The phone's side of pushes: the device token and the taps.
abstract interface class PushMessages {
  /// The notification channel and the listeners; once, at start.
  Future<void> init();

  /// Asks for permission (Android 13+) the first time; null when the phone
  /// can't receive pushes.
  Future<String?> token();

  Stream<String> get tokenRefresh;

  /// Taps on a push while the app runs (in the background or open).
  Stream<PushTap> get taps;

  /// The push that launched the app from closed, if any.
  Future<PushTap?> initialTap();
}

/// Android: Firebase Cloud Messaging. A push that comes while the app is open
/// is not shown by Android itself, so it is shown here, in the same
/// «orders» channel the backend sends to.
class FirebasePushMessages implements PushMessages {
  final _local = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<PushTap>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];

  /// The backend's `FcmPushSender.AndroidChannelId`. Its sound is «гам»
  /// (res/raw/gam.wav). Android fixes a channel's sound when it is created,
  /// so a new sound means a new channel id.
  static const _channel = AndroidNotificationChannel(
    'order_updates',
    'Замовлення',
    description: 'Прийнято, готове, скасовано, оцінка',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('gam'),
  );

  /// The first channel, without the sound; gone from the phone's settings.
  static const _oldChannelIds = ['orders'];

  @override
  Future<void> init() async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
        _taps.add(
          PushTap.fromData(jsonDecode(payload) as Map<String, dynamic>),
        );
      },
    );
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);
    for (final id in _oldChannelIds) {
      await android?.deleteNotificationChannel(channelId: id);
    }
    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_showWhileOpen))
      ..add(
        FirebaseMessaging.onMessageOpenedApp.listen(
          (message) => _taps.add(PushTap.fromData(message.data)),
        ),
      );
  }

  Future<void> _showWhileOpen(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _local.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          sound: _channel.sound,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  @override
  Future<String?> token() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      // The registration token the backend's FCM v1 `token` sends to. The
      // newer register()/onRegistered give an installation id instead.
      // ignore: deprecated_member_use
      return await FirebaseMessaging.instance.getToken();
    } on Object catch (error) {
      // E.g. no Google Play services on this phone.
      developer.log('No push token', name: 'push', error: error);
      return null;
    }
  }

  @override
  // See token(): the registration token, not the installation id.
  // ignore: deprecated_member_use
  Stream<String> get tokenRefresh => FirebaseMessaging.instance.onTokenRefresh;

  @override
  Stream<PushTap> get taps => _taps.stream;

  @override
  Future<PushTap?> initialTap() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    return message == null ? null : PushTap.fromData(message.data);
  }
}

/// iPhone: no pushes without an Apple Developer account; live updates come
/// over SignalR while the app is open.
class NoPushMessages implements PushMessages {
  @override
  Future<void> init() async {}

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefresh => const Stream.empty();

  @override
  Stream<PushTap> get taps => const Stream.empty();

  @override
  Future<PushTap?> initialTap() async => null;
}

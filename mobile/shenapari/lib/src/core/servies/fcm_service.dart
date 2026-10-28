import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';

class FCMService {
  final firebaseMessaging = FirebaseMessaging.instance;

  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permission granted for messages');
    } else {
      debugPrint('Permission denied for messages');
    }
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      if (token != null) {
        AppPreference.setFcmToken(token);
        return token;
      } else {
        debugPrint("Failed to get FCM token");
        return null;
      }
    } catch (e) {
      debugPrint("Get FCM token Error: $e");
      return null;
    }
  }
}

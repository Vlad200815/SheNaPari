import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shenapari/src/app/localization.dart';
import 'package:shenapari/src/core/base/base_application.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';
import 'package:shenapari/src/features/app/app_page.dart';

import 'firebase_options.dart';
import 'src/core/di/di.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.data}');
}

void main() async {
  /// Splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// Pre-load into notifiers so redirect is always sync
  authNotifier.value = await AppPreference.isAuthenticated;
  introNotifier.value = await AppPreference.isShowedIntro;

  /// Configure Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Setup orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// DI
  Di.setup();

  /// Localization
  await Localization.init();

  /// Only enable Crashlytics in release mode
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  /// Check if Crashlytics is enabled
  if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
    ///Capture Flutter framework errors (UI/Widget build errors)
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    /// Capture asynchronous errors (Futures/Streams/Compute)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Remove the splash screen
  FlutterNativeSplash.remove();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Localization.localizedApp(AppPage()),
    ),
  );
}

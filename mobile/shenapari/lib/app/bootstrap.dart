import 'dart:developer' as developer;

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/session/session_repository.dart';
import '../core/storage/app_prefs.dart';
import '../core/storage/token_storage.dart';
import 'app.dart';
import 'di.dart';
import 'router/app_router.dart';

Future<void> bootstrap() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash on screen until the session status is known,
  // so the user never sees an intermediate screen flash by.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  try {
    setupDi(prefs: await SharedPreferences.getInstance());
    runApp(
      App(
        router: createRouter(session: sl(), prefs: sl()),
      ),
    );
    await startSession(session: sl(), tokenStorage: sl(), prefs: sl());
  } finally {
    FlutterNativeSplash.remove();
  }
}

/// Reads the stored session. On the first launch after an install it drops
/// whatever is in the secure storage first: the iOS Keychain survives an
/// uninstall, so a reinstalled app would otherwise start signed in.
Future<void> startSession({
  required SessionRepository session,
  required TokenStorage tokenStorage,
  required AppPrefs prefs,
}) async {
  if (!prefs.launchedBefore) {
    try {
      await tokenStorage.clear();
    } catch (e, stackTrace) {
      developer.log(
        'Failed to clear the secure storage',
        name: 'bootstrap',
        error: e,
        stackTrace: stackTrace,
      );
    }
    await prefs.setLaunchedBefore();
  }
  await session.restore();
}

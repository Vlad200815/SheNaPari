import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

import 'package:easy_localization/easy_localization.dart'
    show AssetLoader, EasyLocalization, RootBundleAssetLoader;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/foundation.dart'
    show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shenapari_core/l10n/app_locale.dart';
import 'package:shenapari_core/session/session_repository.dart';
import 'package:shenapari_core/storage/app_prefs.dart';
import 'package:shenapari_core/storage/token_storage.dart';
import '../features/auth/domain/usecases/sign_out_use_case.dart';
import '../core/device/rive_support.dart';
import '../features/push/presentation/push_coordinator.dart';
import '../firebase_options.dart';
import 'app.dart';
import 'di.dart';
import 'router/app_router.dart';

Future<void> bootstrap() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash on screen until the session status is known,
  // so the user never sees an intermediate screen flash by.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  try {
    await EasyLocalization.ensureInitialized();
    // The rating stars; without it they fall back to drawn ones.
    await RiveSupport.init();
    LicenseRegistry.addLicense(
      () => Stream.value(
        const LicenseEntryWithLineBreaks(
          ['Rating animation (Rive)'],
          '«Rating animation» by JcToon, '
          'https://rive.app/marketplace/405-6776-rating-animation/\n'
          'Licensed under CC BY 4.0: '
          'https://creativecommons.org/licenses/by/4.0/',
        ),
      ),
    );
    // Pushes are Android-only; iPhones get live updates over SignalR.
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    setupDi(prefs: await SharedPreferences.getInstance());
    final router = createRouter(
      session: sl(),
      prefs: sl(),
      signOut: sl<SignOutUseCase>().call,
    );
    runApp(
      localized(
        locale: sl<AppLocale>().locale,
        child: App(router: router),
      ),
    );
    // A tapped push opens its order over whatever is on screen, after the
    // frame in which the router settles on the signed-in screens.
    unawaited(
      sl<PushCoordinator>().start(
        open: (location) => WidgetsBinding.instance.addPostFrameCallback(
          (_) => router.push(location),
        ),
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

/// The texts in `assets/translations`, starting in [locale] (see
/// [AppLocale]). The choice is kept in AppPrefs, not by easy_localization.
Widget localized({
  required Locale locale,
  required Widget child,
  AssetLoader assetLoader = const RootBundleAssetLoader(),
}) => EasyLocalization(
  supportedLocales: AppLocale.supportedLocales,
  path: 'assets/translations',
  startLocale: locale,
  fallbackLocale: const Locale('uk'),
  saveLocale: false,
  // Off by default; on, `plural` uses the real rules (1 порція, 2 порції,
  // 5 порцій) instead of only zero/one/other.
  ignorePluralRules: false,
  assetLoader: assetLoader,
  child: child,
);

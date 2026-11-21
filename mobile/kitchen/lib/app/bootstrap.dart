import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart'
    show AssetLoader, EasyLocalization, RootBundleAssetLoader;
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari_core/session/session_repository.dart';
import 'package:shenapari_core/storage/app_prefs.dart';
import 'package:shenapari_core/storage/token_storage.dart';

import '../features/auth/domain/usecases/sign_out_use_case.dart';
import 'app.dart';
import 'di.dart';
import 'router/app_router.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  setupDi(prefs: await SharedPreferences.getInstance());
  runApp(
    localized(
      child: KitchenApp(
        router: createRouter(session: sl(), signOut: sl<SignOutUseCase>().call),
      ),
    ),
  );
  await startSession(session: sl(), tokenStorage: sl(), prefs: sl());
}

/// Reads the stored session. On the first launch after an install it drops
/// what the iOS Keychain kept from a previous install first.
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

/// The texts in `assets/translations`: Ukrainian only, whatever the
/// tablet's language (the server gets `Accept-Language: uk` too).
Widget localized({
  required Widget child,
  AssetLoader assetLoader = const RootBundleAssetLoader(),
}) => EasyLocalization(
  supportedLocales: const [Locale('uk')],
  path: 'assets/translations',
  startLocale: const Locale('uk'),
  fallbackLocale: const Locale('uk'),
  saveLocale: false,
  ignorePluralRules: false,
  assetLoader: assetLoader,
  child: child,
);

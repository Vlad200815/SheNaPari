import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart'
    show AssetLoader, EasyLocalization, RootBundleAssetLoader;
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari_core/l10n/app_locale.dart';
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
      locale: sl<AppLocale>().locale,
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

/// The texts in `assets/translations`, in the phone's language (uk or en).
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
  ignorePluralRules: false,
  assetLoader: assetLoader,
  child: child,
);

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_locale.dart';
import 'network/dio_factory.dart';
import 'session/session_cubit.dart';
import 'session/session_repository.dart';
import 'session/session_repository_impl.dart';
import 'storage/app_prefs.dart';
import 'storage/secure_token_storage.dart';
import 'storage/token_storage.dart';

/// Registers the shared services (prefs, locale, tokens, session, Dio). [tokenStorage] can be replaced in tests.
void registerCore(
  GetIt sl, {
  required String apiBaseUrl,
  required SharedPreferences prefs,
  TokenStorage? tokenStorage,
}) {
  sl
    ..registerSingleton<AppPrefs>(AppPrefs(prefs))
    ..registerLazySingleton<AppLocale>(() => AppLocale(sl()))
    ..registerLazySingleton<TokenStorage>(
      () => tokenStorage ?? SecureTokenStorage(),
    )
    ..registerLazySingleton<SessionRepository>(
      () => SessionRepositoryImpl(sl()),
    )
    ..registerLazySingleton<Dio>(
      () => createDio(
        baseUrl: apiBaseUrl,
        session: sl(),
        languageCode: () => sl<AppLocale>().languageCode,
      ),
    )
    ..registerFactory(() => SessionCubit(sl()));
}

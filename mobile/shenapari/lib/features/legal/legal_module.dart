import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/app_locale.dart';
import 'data/legal_api.dart';
import 'data/legal_repository_impl.dart';
import 'domain/entities/legal_document.dart';
import 'domain/legal_repository.dart';
import 'presentation/legal_cubit.dart';

void registerLegal(GetIt sl, {required SharedPreferences prefs}) {
  sl
    ..registerLazySingleton<LegalApi>(() => LegalApi(sl()))
    ..registerLazySingleton<LegalRepository>(
      () => LegalRepositoryImpl(
        sl(),
        prefs,
        loadAsset: rootBundle.loadString,
        languageCode: () => sl<AppLocale>().languageCode,
      ),
    )
    ..registerFactoryParam<LegalCubit, LegalDocumentType, void>(
      (type, _) => LegalCubit(sl(), type),
    );
}

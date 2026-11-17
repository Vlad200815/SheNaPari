import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/menu_api.dart';
import 'data/menu_repository_impl.dart';
import 'domain/menu_repository.dart';
import 'domain/usecases/get_menu_use_case.dart';
import 'presentation/home/home_cubit.dart';

void registerMenu(GetIt sl) {
  sl
    ..registerLazySingleton<MenuApi>(() => MenuApi(sl()))
    ..registerLazySingleton<MenuRepository>(
      () => MenuRepositoryImpl(sl(), baseUrl: sl<Dio>().options.baseUrl),
    )
    ..registerFactory(() => GetMenuUseCase(sl()))
    ..registerFactory(() => HomeCubit(sl()));
}

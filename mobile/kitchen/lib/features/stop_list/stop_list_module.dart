import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/stop_list_api.dart';
import 'data/stop_list_repository_impl.dart';
import 'domain/stop_list_repository.dart';
import 'domain/usecases/get_stop_list_use_case.dart';
import 'presentation/stop_list_cubit.dart';

void registerStopList(GetIt sl) {
  sl
    ..registerLazySingleton<StopListApi>(() => StopListApi(sl<Dio>()))
    ..registerLazySingleton<StopListRepository>(
      () => StopListRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetStopListUseCase(sl()))
    ..registerFactory(() => StopListCubit(sl(), sl()));
}

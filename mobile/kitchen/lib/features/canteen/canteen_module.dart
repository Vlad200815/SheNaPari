import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/canteen_api.dart';
import 'data/canteen_repository_impl.dart';
import 'domain/canteen_repository.dart';
import 'presentation/canteen_cubit.dart';

/// Needs the queue module's [OrderEvents] (one SignalR connection).
void registerCanteen(GetIt sl) {
  sl
    ..registerLazySingleton<CanteenApi>(() => CanteenApi(sl<Dio>()))
    ..registerLazySingleton<CanteenRepository>(
      () => CanteenRepositoryImpl(sl()),
    )
    ..registerFactory(() => CanteenCubit(sl(), sl()));
}

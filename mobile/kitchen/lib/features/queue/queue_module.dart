import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shenapari_core/orders/order_events.dart';
import 'package:shenapari_core/orders/signalr_order_events.dart';

import '../../core/device/new_order_alert.dart';
import 'data/queue_api.dart';
import 'data/queue_repository_impl.dart';
import 'domain/queue_repository.dart';
import 'presentation/queue_cubit.dart';

void registerQueue(GetIt sl, {required String apiBaseUrl}) {
  sl
    ..registerLazySingleton<QueueApi>(() => QueueApi(sl<Dio>()))
    ..registerLazySingleton<QueueRepository>(() => QueueRepositoryImpl(sl()))
    ..registerLazySingleton<OrderEvents>(
      () => SignalROrderEvents(baseUrl: apiBaseUrl, session: sl()),
    )
    ..registerLazySingleton<NewOrderAlert>(SoundNewOrderAlert.new)
    ..registerFactory(() => QueueCubit(sl(), sl(), sl()));
}

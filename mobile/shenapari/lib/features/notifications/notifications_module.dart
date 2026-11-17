import 'package:get_it/get_it.dart';

import 'data/notifications_api.dart';
import 'data/notifications_repository_impl.dart';
import 'domain/notifications_repository.dart';
import 'presentation/notifications_cubit.dart';

void registerNotifications(GetIt sl) {
  sl
    ..registerLazySingleton<NotificationsApi>(() => NotificationsApi(sl()))
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(sl()),
    )
    ..registerFactory(() => NotificationsCubit(sl(), sl()))
    ..registerFactory(() => UnreadNotificationsCubit(sl(), sl()));
}

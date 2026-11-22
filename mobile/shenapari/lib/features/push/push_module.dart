import 'dart:io';

import 'package:get_it/get_it.dart';

import '../../core/device/notification_permission.dart';
import '../../core/device/push_messages.dart';
import 'data/push_api.dart';
import 'data/push_repository_impl.dart';
import 'domain/push_repository.dart';
import 'presentation/notification_nudge_cubit.dart';
import 'presentation/push_coordinator.dart';

/// Pushes are Android-only (no Apple Developer account).
void registerPush(GetIt sl) {
  sl
    ..registerLazySingleton<PushMessages>(
      () => Platform.isAndroid ? FirebasePushMessages() : NoPushMessages(),
    )
    ..registerLazySingleton<PushApi>(() => PushApi(sl()))
    ..registerLazySingleton<PushRepository>(() => PushRepositoryImpl(sl()))
    ..registerLazySingleton(() => PushCoordinator(sl(), sl(), sl()))
    ..registerLazySingleton<NotificationPermission>(
      () => Platform.isAndroid
          ? SystemNotificationPermission()
          : NoNotificationPermission(),
    )
    ..registerFactory(() => NotificationNudgeCubit(sl(), sl()));
}

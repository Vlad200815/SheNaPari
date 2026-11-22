import 'package:get_it/get_it.dart';

import '../../core/device/handed_over_sound.dart';
import 'presentation/pickup_cubit.dart';

/// Pickup reuses the queue's repository (the same `/staff/orders` API).
void registerPickup(GetIt sl) => sl
  ..registerLazySingleton<HandedOverSound>(AudioHandedOverSound.new)
  ..registerFactory(() => PickupCubit(sl(), sl()));

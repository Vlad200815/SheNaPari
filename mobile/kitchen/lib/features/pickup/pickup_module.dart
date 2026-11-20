import 'package:get_it/get_it.dart';

import 'presentation/pickup_cubit.dart';

/// Pickup reuses the queue's repository (the same `/staff/orders` API).
void registerPickup(GetIt sl) => sl.registerFactory(() => PickupCubit(sl()));

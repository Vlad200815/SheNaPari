import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/session/session_repository.dart';
import 'data/cart_repository_impl.dart';
import 'domain/cart_repository.dart';
import 'presentation/cart_cubit.dart';

void registerCart(GetIt sl, {required SharedPreferences prefs}) {
  sl
    ..registerLazySingleton<CartRepository>(() => CartRepositoryImpl(prefs))
    // A singleton on purpose: one cart shared by every screen.
    ..registerLazySingleton(
      () => CartCubit(
        sl(),
        sessionChanges: sl<SessionRepository>().statusChanges,
      ),
    );
}

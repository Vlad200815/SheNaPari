import 'package:get_it/get_it.dart';
import 'package:shenapari/src/core/network/interceptors/dio_builder.dart';
import 'package:shenapari/src/features/auth/di/auth_locator.dart';
import 'package:shenapari/src/features/info/di/info_locator.dart';
import 'package:shenapari/src/features/menu/di/menu_locator.dart';
import 'package:shenapari/src/features/profile/di/profile_locator.dart';

final di = GetIt.instance;

class Di {
  static void setup() async {
    /// Register Dio Builder
    di.registerLazySingleton<DioBuilder>(() => DioBuilder.getInstance());

    AuthLocator().inject();
    MenuLocator().inject();
    InfoLocator().inject();
    ProfileLocator().inject();
  }
}

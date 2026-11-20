import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/staff_auth_api.dart';
import 'data/staff_auth_repository_impl.dart';
import 'domain/staff_auth_repository.dart';
import 'domain/usecases/sign_out_use_case.dart';
import 'presentation/login/login_cubit.dart';

void registerAuth(GetIt sl) {
  sl
    ..registerLazySingleton<StaffAuthApi>(() => StaffAuthApi(sl<Dio>()))
    ..registerLazySingleton<StaffAuthRepository>(
      () => StaffAuthRepositoryImpl(sl()),
    )
    ..registerFactory(() => SignOutUseCase(sl(), sl()))
    ..registerFactory(() => LoginCubit(sl(), sl()));
}

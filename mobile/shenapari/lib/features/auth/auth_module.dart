import 'package:get_it/get_it.dart';

import 'data/auth_api.dart';
import 'data/auth_repository_impl.dart';
import 'domain/auth_repository.dart';
import 'domain/usecases/sign_out_use_case.dart';
import 'domain/usecases/verify_code_use_case.dart';
import 'presentation/code/code_cubit.dart';
import 'presentation/phone/phone_cubit.dart';

void registerAuth(GetIt sl) {
  sl
    ..registerLazySingleton<AuthApi>(() => AuthApi(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerFactory(() => VerifyCodeUseCase(sl(), sl()))
    ..registerFactory(() => SignOutUseCase(sl(), sl()))
    ..registerFactory(() => PhoneCubit(sl()))
    // The code screen needs the phone number it was opened for.
    ..registerFactoryParam<CodeCubit, String, void>(
      (phone, _) => CodeCubit(sl(), sl(), phone: phone),
    );
}

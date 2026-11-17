import 'package:get_it/get_it.dart';

import 'data/profile_api.dart';
import 'data/profile_repository_impl.dart';
import 'domain/profile_repository.dart';
import 'domain/usecases/complete_registration_use_case.dart';
import 'presentation/registration_profile/registration_cubit.dart';

void registerProfile(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileApi>(() => ProfileApi(sl()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerFactory(() => CompleteRegistrationUseCase(sl(), sl()))
    ..registerFactory(() => RegistrationCubit(sl()));
}

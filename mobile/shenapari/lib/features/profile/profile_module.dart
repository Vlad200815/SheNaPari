import 'package:get_it/get_it.dart';

import 'data/profile_api.dart';
import 'data/profile_repository_impl.dart';
import 'domain/profile_repository.dart';
import 'domain/usecases/complete_registration.dart';
import 'presentation/registration_profile/registration_cubit.dart';

void registerProfile(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileApi>(() => ProfileApi(sl()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerFactory(() => CompleteRegistration(sl(), sl()))
    ..registerFactory(() => RegistrationCubit(sl()));
}

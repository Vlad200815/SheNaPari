import 'package:get_it/get_it.dart';

import 'data/profile_api.dart';
import 'data/profile_repository_impl.dart';
import 'domain/profile_repository.dart';
import 'domain/usecases/complete_registration_use_case.dart';
import 'domain/usecases/delete_account_use_case.dart';
import 'presentation/more/me_cubit.dart';
import 'presentation/my_profile/edit_profile_cubit.dart';
import 'presentation/profile/delete_account_cubit.dart';
import 'presentation/settings/settings_cubit.dart';
import 'presentation/registration_profile/registration_cubit.dart';

void registerProfile(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileApi>(() => ProfileApi(sl()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerFactory(() => CompleteRegistrationUseCase(sl(), sl()))
    ..registerFactory(() => RegistrationCubit(sl()))
    ..registerFactory(() => DeleteAccountUseCase(sl(), sl()))
    ..registerFactory(() => DeleteAccountCubit(sl()))
    ..registerFactory(() => MeCubit(sl()))
    ..registerFactory(() => EditProfileCubit(sl()))
    ..registerFactory(() => SettingsCubit(sl(), sl(), sl()));
}

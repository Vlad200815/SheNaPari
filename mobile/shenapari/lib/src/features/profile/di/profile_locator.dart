import 'package:shenapari/src/core/di/di.dart';
import 'package:shenapari/src/core/network/interceptors/dio_builder.dart';
import 'package:shenapari/src/features/profile/data/data_sources/remote/profile_api_service.dart';

class ProfileLocator {
  void inject() {
    /// Auth Api Service
    di.registerLazySingleton<ProfileApiService>(
      () => ProfileApiService(di.get<DioBuilder>()),
    );

    // di.registerLazySingleton<ProfileRepository>(
    //       () => ProfileRepositoryImpl(apiService: di.get()),
    // );
  }
}

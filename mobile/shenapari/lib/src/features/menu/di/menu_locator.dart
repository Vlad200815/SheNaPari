import 'package:shenapari/src/core/di/di.dart';
import 'package:shenapari/src/features/menu/domain/usecases/fetch_posters_usecase.dart';
import 'package:shenapari/src/features/menu/domain/usecases/fetch_products_usecase.dart';

import '../data/repositories/menu_repository_impl.dart';
import '../domain/repositories/menu_repository.dart';

class MenuLocator {
  void inject() {
    // /// Auth Api Service
    // di.registerLazySingleton<AuthApiService>(
    //       () => AuthApiService(di.get<DioBuilder>()),
    // );
    //
    di.registerLazySingleton<MenuRepository>(() => MenuRepositoryImpl());

    di.registerLazySingleton<FetchPostersUseCase>(
      () => FetchPostersUseCase(homeRepository: di.get()),
    );
    di.registerLazySingleton<FetchProductsUseCase>(
      () => FetchProductsUseCase(homeRepository: di.get()),
    );
  }
}

import 'package:shenapari/src/core/di/di.dart';
import 'package:shenapari/src/features/info/data/repositories/info_repository_impl.dart';
import 'package:shenapari/src/features/info/domain/repositories/info_repository.dart';
import 'package:shenapari/src/features/info/domain/usecases/fetch_privacy_policy.dart';
import 'package:shenapari/src/features/info/domain/usecases/fetch_terms_of_use.dart';

class InfoLocator {
  void inject() {
    di.registerLazySingleton<InfoRepository>(() => InfoRepositoryImpl());

    di.registerLazySingleton<FetchPrivacyPolicyUseCase>(
      () => FetchPrivacyPolicyUseCase(legalRepository: di.get()),
    );
    di.registerLazySingleton<FetchTermsOfUseUseCase>(
      () => FetchTermsOfUseUseCase(legalRepository: di.get()),
    );
  }
}

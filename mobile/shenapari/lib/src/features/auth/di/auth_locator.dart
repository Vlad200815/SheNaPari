import 'package:flutter/foundation.dart';
import 'package:shenapari/src/core/di/di.dart';
import 'package:shenapari/src/core/network/interceptors/dio_builder.dart';
import 'package:shenapari/src/features/auth/data/data_sources/remote/auth_api_service.dart';
import 'package:shenapari/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shenapari/src/features/auth/domain/repositories/auth_repository.dart';

import '../domain/usecases/resend_otp_code_usecase.dart';
import '../domain/usecases/send_otp_code_usecase.dart';
import '../domain/usecases/verify_otp_code_usecase.dart';

class AuthLocator {
  void inject() {
    /// Auth Api Service
    di.registerLazySingleton<AuthApiService>(
      () => AuthApiService(di.get<DioBuilder>()),
    );

    di.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(apiService: di.get()),
    );

    /// Send Otp Code Use Case
    di.registerLazySingleton<SendOtpCodeUseCase>(
      () => SendOtpCodeUseCase(authRepository: di.get()),
    );

    /// Resend Opt Code
    di.registerLazySingleton<ResendOtpCodeUseCase>(
      () => ResendOtpCodeUseCase(authRepository: di.get()),
    );

    /// Verify Opt Code
    di.registerLazySingleton<VerifyOtpCodeUseCase>(
      () => VerifyOtpCodeUseCase(authRepository: di.get()),
    );

    debugPrint("AUTH-REGISTERED");
  }
}

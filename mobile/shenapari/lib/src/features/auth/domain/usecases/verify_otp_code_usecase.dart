import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/usecase.dart';
import 'package:shenapari/src/features/auth/domain/entities/auth.dart';
import 'package:shenapari/src/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpCodeUseCase
    extends Functions3<String, String, String, Result<JWTEntity>> {
  final AuthRepository _authRepository;

  VerifyOtpCodeUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<JWTEntity>> perform(phoneNumber, otpCode, fcmToken) async {
    return await _authRepository.verifyOtpCode(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      fcmToken: fcmToken,
    );
  }
}

import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/usecase.dart';
import 'package:shenapari/src/features/auth/domain/entities/auth.dart';
import 'package:shenapari/src/features/auth/domain/repositories/auth_repository.dart';

class SendOtpCodeUseCase extends Functions1<String, Result<OtpEntity>> {
  final AuthRepository _authRepository;

  SendOtpCodeUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Result<OtpEntity>> perform(String phoneNumber) async {
    return await _authRepository.sendOtpCode(phoneNumber: phoneNumber);
  }
}

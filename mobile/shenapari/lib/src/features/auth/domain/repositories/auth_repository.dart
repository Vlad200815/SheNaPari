import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/features/auth/domain/entities/auth.dart';

abstract interface class AuthRepository {
  /// Send OTP code
  Future<Result<OtpEntity>> sendOtpCode({required String phoneNumber});

  /// Resend Otp Code
  Future<Result<OtpEntity>> resendOtpCode({required String phoneNumber});

  /// Verify Otp Code
  Future<Result<JWTEntity>> verifyOtpCode({
    required String phoneNumber,
    required String otpCode,
    required String fcmToken,
  });
}

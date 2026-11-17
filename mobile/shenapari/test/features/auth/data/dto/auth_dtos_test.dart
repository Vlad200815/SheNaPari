import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/features/auth/data/dto/auth_dtos.dart';
import 'package:shenapari/features/auth/domain/entities/sign_in.dart';

void main() {
  test('AuthResponseDto reads the server answer and maps isNew', () {
    final dto = AuthResponseDto.fromJson({
      'accessToken': 'a',
      'refreshToken': 'r',
      'isNew': true,
    });

    expect(
      dto.toEntity(),
      const SignIn(
        tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
        isNewUser: true,
      ),
    );
  });

  test('request DTOs use the field names of the API', () {
    expect(const OtpRequestDto(phone: '+380671234567').toJson(), {
      'phone': '+380671234567',
    });
    expect(
      const OtpVerifyDto(phone: '+380671234567', code: '123456').toJson(),
      {'phone': '+380671234567', 'code': '123456'},
    );
    expect(const RefreshDto(refreshToken: 'r').toJson(), {'refreshToken': 'r'});
  });
}

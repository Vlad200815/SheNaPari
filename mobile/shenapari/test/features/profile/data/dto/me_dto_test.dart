import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/profile/data/dto/me_dto.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';

void main() {
  test('reads a customer from GET /me', () {
    final user = MeDto.fromJson({
      'id': '3f2a',
      'role': 'Customer',
      'name': 'Влад',
      'phone': '+380671234567',
      'email': null,
    }).toEntity();

    expect(
      user,
      const User(
        id: '3f2a',
        role: UserRole.customer,
        name: 'Влад',
        phone: '+380671234567',
      ),
    );
  });

  test('roles come in PascalCase; unknown ones do not crash', () {
    expect(MeDto.parseRole('Cook'), UserRole.cook);
    expect(MeDto.parseRole('SuperAdmin'), UserRole.superAdmin);
    expect(MeDto.parseRole('Courier'), UserRole.unknown);
    expect(MeDto.parseRole(''), UserRole.unknown);
  });
}

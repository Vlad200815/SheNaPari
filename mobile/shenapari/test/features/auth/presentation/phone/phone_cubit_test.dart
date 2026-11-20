import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/presentation/phone/phone_cubit.dart';
import 'package:shenapari/features/auth/presentation/phone/phone_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _complete = PhoneState(digits: '671234567');

void main() {
  late _MockAuthRepository auth;

  setUp(() => auth = _MockAuthRepository());

  void answer(Result<void> result) => when(
    () => auth.requestCode(phone: '+380671234567'),
  ).thenAnswer((_) async => result);

  test('PhoneState builds the number for the server', () {
    expect(_complete.phone, '+380671234567');
    expect(_complete.isComplete, isTrue);
    expect(const PhoneState(digits: '67123').isComplete, isFalse);
  });

  blocTest<PhoneCubit, PhoneState>(
    'phoneChanged keeps only the digits and resets an old failure',
    build: () => PhoneCubit(auth),
    seed: () => const PhoneState(
      status: PhoneStatus.failure,
      failure: NetworkFailure(),
    ),
    act: (cubit) => cubit.phoneChanged('67 123 45 67'),
    expect: () => [_complete],
  );

  blocTest<PhoneCubit, PhoneState>(
    'submit sends the code and emits [sending, sent]',
    setUp: () => answer(const Ok(null)),
    build: () => PhoneCubit(auth),
    seed: () => _complete,
    act: (cubit) => cubit.submit(),
    expect: () => [
      _complete.copyWith(status: PhoneStatus.sending),
      _complete.copyWith(status: PhoneStatus.sent),
    ],
  );

  blocTest<PhoneCubit, PhoneState>(
    'submit shows the server failure',
    setUp: () => answer(
      const Err(
        ValidationFailure(
          'Номер має бути у форматі +380XXXXXXXXX',
          code: 'auth.invalid_phone',
        ),
      ),
    ),
    build: () => PhoneCubit(auth),
    seed: () => _complete,
    act: (cubit) => cubit.submit(),
    expect: () => [
      _complete.copyWith(status: PhoneStatus.sending),
      _complete.copyWith(
        status: PhoneStatus.failure,
        failure: const ValidationFailure(
          'Номер має бути у форматі +380XXXXXXXXX',
          code: 'auth.invalid_phone',
        ),
      ),
    ],
  );

  blocTest<PhoneCubit, PhoneState>(
    'a code sent less than a minute ago still lets the user go on',
    setUp: () => answer(
      const Err(
        ServerFailure(
          'Новий код можна запросити через 60 секунд',
          code: 'auth.too_many_requests',
        ),
      ),
    ),
    build: () => PhoneCubit(auth),
    seed: () => _complete,
    act: (cubit) => cubit.submit(),
    expect: () => [
      _complete.copyWith(status: PhoneStatus.sending),
      _complete.copyWith(status: PhoneStatus.sent),
    ],
  );

  blocTest<PhoneCubit, PhoneState>(
    'submit does nothing while the number is incomplete',
    build: () => PhoneCubit(auth),
    seed: () => const PhoneState(digits: '6712'),
    act: (cubit) => cubit.submit(),
    expect: () => <PhoneState>[],
    verify: (_) =>
        verifyNever(() => auth.requestCode(phone: any(named: 'phone'))),
  );
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/profile/domain/usecases/complete_registration.dart';
import 'package:shenapari/features/profile/presentation/registration_profile/registration_cubit.dart';
import 'package:shenapari/features/profile/presentation/registration_profile/registration_state.dart';

class _MockCompleteRegistration extends Mock implements CompleteRegistration {}

const _named = RegistrationState(name: 'Влад');

void main() {
  late _MockCompleteRegistration completeRegistration;

  setUp(() => completeRegistration = _MockCompleteRegistration());

  test('a name shorter than 2 characters cannot be submitted', () {
    expect(const RegistrationState(name: ' В ').canSubmit, isFalse);
    expect(_named.canSubmit, isTrue);
  });

  blocTest<RegistrationCubit, RegistrationState>(
    'nameChanged stores the name and resets an old failure',
    build: () => RegistrationCubit(completeRegistration),
    seed: () => const RegistrationState(
      status: RegistrationStatus.failure,
      failure: NetworkFailure(),
    ),
    act: (cubit) => cubit.nameChanged('Влад'),
    expect: () => [_named],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'submit emits [saving, saved]',
    setUp: () => when(
      () => completeRegistration(name: 'Влад'),
    ).thenAnswer((_) async => const Ok(null)),
    build: () => RegistrationCubit(completeRegistration),
    seed: () => _named,
    act: (cubit) => cubit.submit(),
    expect: () => [
      _named.copyWith(status: RegistrationStatus.saving),
      _named.copyWith(status: RegistrationStatus.saved),
    ],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'submit emits [saving, failure] when the server rejects it',
    setUp: () => when(
      () => completeRegistration(name: 'Влад'),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: () => RegistrationCubit(completeRegistration),
    seed: () => _named,
    act: (cubit) => cubit.submit(),
    expect: () => [
      _named.copyWith(status: RegistrationStatus.saving),
      _named.copyWith(
        status: RegistrationStatus.failure,
        failure: const NetworkFailure(),
      ),
    ],
  );
}

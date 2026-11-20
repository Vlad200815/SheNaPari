import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/domain/usecases/verify_code_use_case.dart';
import 'package:shenapari/features/auth/presentation/code/code_cubit.dart';
import 'package:shenapari/features/auth/presentation/code/code_state.dart';

class _MockVerifyCodeUseCase extends Mock implements VerifyCodeUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

const _phone = '+380671234567';
const _wrongCode = ValidationFailure(
  'Невірний або прострочений код',
  code: 'auth.invalid_code',
);

/// No ticking: the resend timer stays where the test put it.
Stream<int> _frozen(int seconds) => const Stream.empty();

void main() {
  late _MockVerifyCodeUseCase verifyCode;
  late _MockAuthRepository auth;

  setUp(() {
    verifyCode = _MockVerifyCodeUseCase();
    auth = _MockAuthRepository();
  });

  CodeCubit build({Countdown countdown = _frozen}) =>
      CodeCubit(verifyCode, auth, phone: _phone, countdown: countdown);

  test('starts with the resend timer at 60 s', () {
    final cubit = build();

    expect(cubit.state, const CodeState(resendIn: 60));
    cubit.close();
  });

  blocTest<CodeCubit, CodeState>(
    'the timer counts down to zero',
    build: () => build(countdown: (_) => Stream.fromIterable([2, 1, 0])),
    expect: () => const [
      CodeState(resendIn: 2),
      CodeState(resendIn: 1),
      CodeState(),
    ],
  );

  group('verify', () {
    blocTest<CodeCubit, CodeState>(
      'right code emits [verifying, success]',
      setUp: () => when(
        () => verifyCode(phone: _phone, code: '123456'),
      ).thenAnswer((_) async => const Ok(null)),
      build: build,
      act: (cubit) => cubit.verify('123456'),
      expect: () => const [
        CodeState(status: CodeStatus.verifying, resendIn: 60),
        CodeState(status: CodeStatus.success, resendIn: 60),
      ],
    );

    blocTest<CodeCubit, CodeState>(
      'wrong code emits [verifying, failure]',
      setUp: () => when(
        () => verifyCode(phone: _phone, code: '000000'),
      ).thenAnswer((_) async => const Err(_wrongCode)),
      build: build,
      act: (cubit) => cubit.verify('000000'),
      expect: () => const [
        CodeState(status: CodeStatus.verifying, resendIn: 60),
        CodeState(
          status: CodeStatus.failure,
          resendIn: 60,
          failure: _wrongCode,
        ),
      ],
    );

    blocTest<CodeCubit, CodeState>(
      'ignores an incomplete code',
      build: build,
      act: (cubit) => cubit.verify('123'),
      expect: () => <CodeState>[],
    );
  });

  group('resend', () {
    blocTest<CodeCubit, CodeState>(
      'is ignored while the timer runs',
      build: build,
      act: (cubit) => cubit.resend(),
      expect: () => <CodeState>[],
      verify: (_) =>
          verifyNever(() => auth.requestCode(phone: any(named: 'phone'))),
    );

    blocTest<CodeCubit, CodeState>(
      'after the timer sends a new code and restarts the timer',
      setUp: () => when(
        () => auth.requestCode(phone: _phone),
      ).thenAnswer((_) async => const Ok(null)),
      build: build,
      seed: () => const CodeState(),
      act: (cubit) => cubit.resend(),
      expect: () => const [
        CodeState(status: CodeStatus.resending),
        CodeState(resendIn: 60),
      ],
    );

    blocTest<CodeCubit, CodeState>(
      'shows the failure when the code cannot be sent',
      setUp: () => when(
        () => auth.requestCode(phone: _phone),
      ).thenAnswer((_) async => const Err(NetworkFailure())),
      build: build,
      seed: () => const CodeState(),
      act: (cubit) => cubit.resend(),
      expect: () => const [
        CodeState(status: CodeStatus.resending),
        CodeState(status: CodeStatus.failure, failure: NetworkFailure()),
      ],
    );
  });

  test('secondsCountdown counts seconds-1 down to 0', () async {
    expect(await secondsCountdown(3).toList(), [2, 1, 0]);
  });
}

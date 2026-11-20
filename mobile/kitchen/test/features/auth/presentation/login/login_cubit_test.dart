import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:kitchen/features/auth/presentation/login/login_cubit.dart';
import 'package:kitchen/features/auth/presentation/login/login_state.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/session/session_repository_impl.dart';
import 'package:shenapari_core/session/session_status.dart';
import 'package:shenapari_core/storage/in_memory_token_storage.dart';

import '../../../../fakes.dart';

void main() {
  late FakeStaffAuthRepository auth;
  late SessionRepositoryImpl session;

  setUp(() async {
    auth = FakeStaffAuthRepository();
    session = SessionRepositoryImpl(InMemoryTokenStorage());
    await session.restore();
  });

  test('the button waits for an e-mail and a password', () {
    final cubit = LoginCubit(auth, session);
    expect(cubit.state.canSubmit, isFalse);

    cubit.emailChanged('cook@shenapari.local');
    expect(cubit.state.canSubmit, isFalse);
    cubit.passwordChanged('x');
    expect(cubit.state.canSubmit, isTrue);

    cubit.emailChanged('cook');
    expect(cubit.state.canSubmit, isFalse, reason: 'not an e-mail');
  });

  test('a right pair signs in: the session says so', () async {
    final cubit = LoginCubit(auth, session)
      ..emailChanged(' cook@shenapari.local ')
      ..passwordChanged('Cook12345!');

    await cubit.submit();

    expect(session.status, SessionStatus.authenticated);
    expect(session.tokens, FakeStaffAuthRepository.tokens);
  });

  test('a wrong pair: the server\'s reason under the field', () async {
    final cubit = LoginCubit(auth, session)
      ..emailChanged('cook@shenapari.local')
      ..passwordChanged('nope');

    await cubit.submit();

    expect(cubit.state.status, LoginStatus.failure);
    expect(cubit.state.failure, isA<UnauthorizedFailure>());
    expect(session.status, SessionStatus.unauthenticated);

    cubit.passwordChanged('nope2');
    expect(cubit.state.failure, isNull, reason: 'typing clears it');
  });

  test('sign-out revokes the token and clears the session', () async {
    await session.save(FakeStaffAuthRepository.tokens, isNewUser: false);

    await SignOutUseCase(auth, session).call();

    expect(auth.logouts, ['r']);
    expect(session.status, SessionStatus.unauthenticated);
  });
}

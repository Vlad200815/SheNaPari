import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/session/session_repository_impl.dart';
import 'package:shenapari/core/session/session_status.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/domain/usecases/sign_out_use_case.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

void main() {
  late _MockAuthRepository auth;
  late SessionRepositoryImpl session;

  setUp(() async {
    auth = _MockAuthRepository();
    session = SessionRepositoryImpl(InMemoryTokenStorage());
    await session.save(_tokens, isNewUser: false);
  });

  tearDown(() => session.dispose());

  test('revokes the refresh token and clears the session', () async {
    when(
      () => auth.logout(refreshToken: 'r'),
    ).thenAnswer((_) async => const Ok(null));

    await SignOutUseCase(auth, session)();

    verify(() => auth.logout(refreshToken: 'r')).called(1);
    expect(session.status, SessionStatus.unauthenticated);
  });

  test('clears the session even when the request fails', () async {
    when(
      () => auth.logout(refreshToken: 'r'),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    await SignOutUseCase(auth, session)();

    expect(session.status, SessionStatus.unauthenticated);
    expect(session.tokens, isNull);
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/session/session_cubit.dart';
import 'package:shenapari/core/session/session_repository_impl.dart';
import 'package:shenapari/core/session/session_status.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';

const _tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

void main() {
  late SessionRepositoryImpl session;

  setUp(() => session = SessionRepositoryImpl(InMemoryTokenStorage()));
  tearDown(() => session.dispose());

  test('initial state is the current session status', () {
    final cubit = SessionCubit(session);

    expect(cubit.state, SessionStatus.unknown);
    cubit.close();
  });

  blocTest<SessionCubit, SessionStatus>(
    'follows the session status',
    build: () => SessionCubit(session),
    act: (_) async {
      await session.restore();
      await session.save(_tokens, isNewUser: false);
      await session.clear();
    },
    expect: () => [
      SessionStatus.unauthenticated,
      SessionStatus.authenticated,
      SessionStatus.unauthenticated,
    ],
  );
}

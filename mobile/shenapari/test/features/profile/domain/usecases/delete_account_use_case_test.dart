import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/session/session_repository_impl.dart';
import 'package:shenapari/core/session/session_status.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';
import 'package:shenapari/features/profile/domain/profile_repository.dart';
import 'package:shenapari/features/profile/domain/usecases/delete_account_use_case.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

const _tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

void main() {
  late _MockProfileRepository profile;
  late SessionRepositoryImpl session;
  late DeleteAccountUseCase deleteAccount;

  setUp(() async {
    profile = _MockProfileRepository();
    session = SessionRepositoryImpl(InMemoryTokenStorage());
    await session.save(_tokens, isNewUser: false);
    deleteAccount = DeleteAccountUseCase(profile, session);
  });

  tearDown(() => session.dispose());

  test('after the server deleted the account the session is gone', () async {
    when(() => profile.deleteAccount()).thenAnswer((_) async => const Ok(null));

    expect(await deleteAccount(), isA<Ok<void>>());
    expect(session.status, SessionStatus.unauthenticated);
    expect(session.tokens, isNull);
  });

  test('a refused deletion keeps the user signed in', () async {
    const failure = ConflictFailure(
      'Спершу заберіть або скасуйте активне замовлення',
      code: 'profile.has_active_order',
    );
    when(
      () => profile.deleteAccount(),
    ).thenAnswer((_) async => const Err(failure));

    expect(await deleteAccount(), const Err<void>(failure));
    expect(session.status, SessionStatus.authenticated);
  });
}

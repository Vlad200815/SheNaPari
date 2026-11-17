import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/core/session/session_repository_impl.dart';
import 'package:shenapari/core/session/session_status.dart';
import 'package:shenapari/core/storage/in_memory_token_storage.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/domain/entities/sign_in.dart';
import 'package:shenapari/features/auth/domain/usecases/verify_code.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');
const _phone = '+380671234567';

void main() {
  late _MockAuthRepository auth;
  late SessionRepositoryImpl session;
  late VerifyCode verifyCode;

  setUp(() async {
    auth = _MockAuthRepository();
    session = SessionRepositoryImpl(InMemoryTokenStorage());
    await session.restore();
    verifyCode = VerifyCode(auth, session);
  });

  tearDown(() => session.dispose());

  void answer(Result<SignIn> result) => when(
    () => auth.verifyCode(phone: _phone, code: '123456'),
  ).thenAnswer((_) async => result);

  test('new customer: session becomes needsProfile', () async {
    answer(const Ok(SignIn(tokens: _tokens, isNewUser: true)));

    final result = await verifyCode(phone: _phone, code: '123456');

    expect(result, isA<Ok<void>>());
    expect(session.status, SessionStatus.needsProfile);
    expect(session.tokens, _tokens);
  });

  test('returning customer: session becomes authenticated', () async {
    answer(const Ok(SignIn(tokens: _tokens, isNewUser: false)));

    await verifyCode(phone: _phone, code: '123456');

    expect(session.status, SessionStatus.authenticated);
  });

  test('wrong code: failure is returned and no session is stored', () async {
    const failure = ValidationFailure(
      'Невірний або прострочений код',
      code: 'auth.invalid_code',
    );
    answer(const Err(failure));

    final result = await verifyCode(phone: _phone, code: '123456');

    expect(result, const Err<void>(failure));
    expect(session.status, SessionStatus.unauthenticated);
    expect(session.tokens, isNull);
  });
}

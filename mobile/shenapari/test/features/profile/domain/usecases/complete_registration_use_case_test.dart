import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/session/auth_tokens.dart';
import 'package:shenapari_core/session/session_repository_impl.dart';
import 'package:shenapari_core/session/session_status.dart';
import 'package:shenapari_core/storage/in_memory_token_storage.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';
import 'package:shenapari/features/profile/domain/profile_repository.dart';
import 'package:shenapari/features/profile/domain/usecases/complete_registration_use_case.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

const _tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');
const _user = User(id: '1', role: UserRole.customer, name: 'Влад');

void main() {
  late _MockProfileRepository profile;
  late SessionRepositoryImpl session;
  late CompleteRegistrationUseCase completeRegistration;

  setUp(() async {
    profile = _MockProfileRepository();
    session = SessionRepositoryImpl(InMemoryTokenStorage());
    await session.save(_tokens, isNewUser: true);
    completeRegistration = CompleteRegistrationUseCase(profile, session);
  });

  tearDown(() => session.dispose());

  test('saves the trimmed name, then the session is authenticated', () async {
    when(
      () => profile.updateName('Влад'),
    ).thenAnswer((_) async => const Ok(_user));

    final result = await completeRegistration(name: '  Влад ');

    expect(result, isA<Ok<void>>());
    verify(() => profile.updateName('Влад')).called(1);
    expect(session.status, SessionStatus.authenticated);
  });

  test('when the name is rejected the profile step stays', () async {
    const failure = ValidationFailure(
      'Ім’я має містити від 2 до 100 символів',
      code: 'profile.invalid_name',
    );
    when(
      () => profile.updateName(any()),
    ).thenAnswer((_) async => const Err(failure));

    final result = await completeRegistration(name: 'В');

    expect(result, const Err<void>(failure));
    expect(session.status, SessionStatus.needsProfile);
  });
}

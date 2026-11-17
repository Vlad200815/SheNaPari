import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:shenapari/features/profile/presentation/profile/delete_account_cubit.dart';

class _MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

void main() {
  late _MockDeleteAccountUseCase deleteAccount;

  setUp(() => deleteAccount = _MockDeleteAccountUseCase());

  blocTest<DeleteAccountCubit, DeleteAccountState>(
    'emits [deleting, deleted]',
    setUp: () =>
        when(() => deleteAccount()).thenAnswer((_) async => const Ok(null)),
    build: () => DeleteAccountCubit(deleteAccount),
    act: (cubit) => cubit.delete(),
    expect: () => const [
      DeleteAccountState(status: DeleteAccountStatus.deleting),
      DeleteAccountState(status: DeleteAccountStatus.deleted),
    ],
  );

  blocTest<DeleteAccountCubit, DeleteAccountState>(
    'emits [deleting, failure] with the reason',
    setUp: () => when(
      () => deleteAccount(),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: () => DeleteAccountCubit(deleteAccount),
    act: (cubit) => cubit.delete(),
    expect: () => const [
      DeleteAccountState(status: DeleteAccountStatus.deleting),
      DeleteAccountState(
        status: DeleteAccountStatus.failure,
        failure: NetworkFailure(),
      ),
    ],
  );

  blocTest<DeleteAccountCubit, DeleteAccountState>(
    'a second tap while deleting is ignored',
    build: () => DeleteAccountCubit(deleteAccount),
    seed: () => const DeleteAccountState(status: DeleteAccountStatus.deleting),
    act: (cubit) => cubit.delete(),
    expect: () => const <DeleteAccountState>[],
    verify: (_) => verifyNever(() => deleteAccount()),
  );
}

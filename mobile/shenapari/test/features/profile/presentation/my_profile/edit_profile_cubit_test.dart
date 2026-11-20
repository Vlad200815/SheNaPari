import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';
import 'package:shenapari/features/profile/presentation/my_profile/edit_profile_cubit.dart';
import 'package:shenapari/features/profile/presentation/widgets/profile_ui.dart';

import '../../../../fakes.dart';

class _RefusingProfile extends FakeProfileRepository {
  @override
  Future<Result<User>> updateName(String name) async => const Err(
    ValidationFailure(
      'Ім\'я має містити від 2 до 100 символів',
      code: 'profile.invalid_name',
    ),
  );
}

void main() {
  test('loads the name; nothing to save until it changes', () async {
    final repo = FakeProfileRepository()..savedName = 'Влад';
    final cubit = EditProfileCubit(repo);

    await cubit.load();

    expect(cubit.state.name, 'Влад');
    expect(cubit.state.canSave, isFalse);
  });

  test('a changed valid name can be saved; trimmed', () async {
    final repo = FakeProfileRepository()..savedName = 'Влад';
    final cubit = EditProfileCubit(repo);
    await cubit.load();

    cubit.nameChanged('  Владислав ');
    expect(cubit.state.canSave, isTrue);
    await cubit.save();

    expect(repo.savedName, 'Владислав');
    expect(cubit.state.savedName, 'Владислав');
    expect(cubit.state.isChanged, isFalse);
    expect(cubit.state.savedCount, 1);
  });

  test('too short a name cannot be saved', () async {
    final cubit = EditProfileCubit(FakeProfileRepository()..savedName = 'Влад');
    await cubit.load();

    cubit.nameChanged(' В ');

    expect(cubit.state.isNameValid, isFalse);
    expect(cubit.state.canSave, isFalse);
  });

  test('a refused save keeps the typed name and shows why', () async {
    final cubit = EditProfileCubit(_RefusingProfile()..savedName = 'Влад');
    await cubit.load();

    cubit.nameChanged('Владислав');
    await cubit.save();

    expect(cubit.state.failure?.code, 'profile.invalid_name');
    expect(cubit.state.name, 'Владислав');
    expect(cubit.state.status, EditProfileStatus.editing);
  });

  test('phone is shown the Ukrainian way', () {
    expect(formatProfilePhone('+380686387145'), '+38 (068) 638-71-45');
    expect(formatProfilePhone('oops'), 'oops');
  });
}

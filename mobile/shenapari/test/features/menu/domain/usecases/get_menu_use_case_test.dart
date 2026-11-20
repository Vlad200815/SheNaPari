import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari/features/menu/domain/entities/menu.dart';
import 'package:shenapari/features/menu/domain/menu_repository.dart';
import 'package:shenapari/features/menu/domain/usecases/get_menu_use_case.dart';

import '../../menu_samples.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late _MockMenuRepository repository;
  late GetMenuUseCase getMenu;

  setUp(() {
    repository = _MockMenuRepository();
    getMenu = GetMenuUseCase(repository);
    when(
      () => repository.getCanteen(),
    ).thenAnswer((_) async => const Ok(sampleCanteen));
    when(
      () => repository.getCategories(),
    ).thenAnswer((_) async => const Ok([burgers, drinks, pastry]));
    when(
      () => repository.getDishes(),
    ).thenAnswer((_) async => const Ok(sampleDishes));
    when(
      () => repository.getNextBreak(),
    ).thenAnswer((_) async => Ok(sampleBreak));
  });

  test('puts the canteen, categories and dishes together', () async {
    expect(await getMenu(), Ok(sampleMenu));
  });

  test('drops categories without dishes', () async {
    final result = await getMenu();

    expect((result as Ok).value.categories, isNot(contains(pastry)));
  });

  test('any failed request fails the whole menu', () async {
    when(
      () => repository.getCategories(),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    expect(await getMenu(), const Err<Menu>(NetworkFailure()));
  });

  test('no scheduled break is fine: nextBreak is null', () async {
    when(
      () => repository.getNextBreak(),
    ).thenAnswer((_) async => const Ok(null));

    final result = await getMenu();

    expect((result as Ok<Menu>).value.nextBreak, isNull);
  });
}

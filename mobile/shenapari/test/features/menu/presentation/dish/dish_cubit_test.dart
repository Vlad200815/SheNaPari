import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari/features/menu/domain/menu_repository.dart';
import 'package:shenapari/features/menu/presentation/dish/dish_cubit.dart';
import 'package:shenapari/features/menu/presentation/dish/dish_state.dart';

import '../../menu_samples.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late _MockMenuRepository menu;

  setUp(() {
    menu = _MockMenuRepository();
    when(() => menu.getNextBreak()).thenAnswer((_) async => Ok(sampleBreak));
  });

  blocTest<DishCubit, DishState>(
    'with the dish from the menu: no loader, only the break is fetched',
    build: () =>
        DishCubit(menu, dishId: cheeseburger.id, initial: cheeseburger),
    act: (cubit) => cubit.load(),
    expect: () => [
      DishState(
        status: DishStatus.loaded,
        dish: cheeseburger,
        nextBreak: sampleBreak,
      ),
    ],
    verify: (_) => verifyNever(() => menu.getDish(any())),
  );

  blocTest<DishCubit, DishState>(
    'without it the dish is loaded by id',
    setUp: () => when(
      () => menu.getDish(cheeseburger.id),
    ).thenAnswer((_) async => const Ok(cheeseburger)),
    build: () => DishCubit(menu, dishId: cheeseburger.id),
    act: (cubit) => cubit.load(),
    expect: () => [
      const DishState(),
      DishState(
        status: DishStatus.loaded,
        dish: cheeseburger,
        nextBreak: sampleBreak,
      ),
    ],
  );

  blocTest<DishCubit, DishState>(
    'a hidden dish shows the failure',
    setUp: () => when(() => menu.getDish(99)).thenAnswer(
      (_) async => const Err(
        NotFoundFailure('Страву не знайдено', code: 'menu.dish_not_found'),
      ),
    ),
    build: () => DishCubit(menu, dishId: 99),
    act: (cubit) => cubit.load(),
    expect: () => [
      const DishState(),
      const DishState(
        status: DishStatus.failure,
        failure: NotFoundFailure(
          'Страву не знайдено',
          code: 'menu.dish_not_found',
        ),
      ),
    ],
  );

  blocTest<DishCubit, DishState>(
    'a failed break request still shows the dish',
    setUp: () => when(
      () => menu.getNextBreak(),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: () =>
        DishCubit(menu, dishId: cheeseburger.id, initial: cheeseburger),
    act: (cubit) => cubit.load(),
    expect: () => [
      const DishState(status: DishStatus.loaded, dish: cheeseburger),
    ],
  );

  blocTest<DishCubit, DishState>(
    'quantity stays within 1–20',
    build: () =>
        DishCubit(menu, dishId: cheeseburger.id, initial: cheeseburger),
    act: (cubit) => cubit
      ..setQuantity(5)
      ..setQuantity(25)
      ..setQuantity(0),
    expect: () => [
      const DishState(
        status: DishStatus.loaded,
        dish: cheeseburger,
        quantity: 5,
      ),
      const DishState(
        status: DishStatus.loaded,
        dish: cheeseburger,
        quantity: 20,
      ),
      const DishState(status: DishStatus.loaded, dish: cheeseburger),
    ],
  );

  test('total = price × quantity', () {
    const state = DishState(dish: cheeseburger, quantity: 3);
    expect(state.totalKopecks, 3 * 8500);
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/menu/domain/entities/menu.dart';
import 'package:shenapari/features/menu/domain/usecases/get_menu_use_case.dart';
import 'package:shenapari/features/menu/presentation/home/home_cubit.dart';
import 'package:shenapari/features/menu/presentation/home/home_state.dart';
import 'package:shenapari/features/menu/presentation/home/menu_filter.dart';

import '../../menu_samples.dart';

class _MockGetMenuUseCase extends Mock implements GetMenuUseCase {}

const _loaded = HomeState(status: HomeStatus.loaded, menu: sampleMenu);

void main() {
  late _MockGetMenuUseCase getMenu;

  setUp(() => getMenu = _MockGetMenuUseCase());

  void answer(Result<Menu> result) =>
      when(() => getMenu()).thenAnswer((_) async => result);

  group('load', () {
    blocTest<HomeCubit, HomeState>(
      'emits [loading, loaded] with the menu',
      setUp: () => answer(const Ok(sampleMenu)),
      build: () => HomeCubit(getMenu),
      act: (cubit) => cubit.load(),
      expect: () => [const HomeState(), _loaded],
    );

    blocTest<HomeCubit, HomeState>(
      'emits failure when there is nothing to show',
      setUp: () => answer(const Err(NetworkFailure())),
      build: () => HomeCubit(getMenu),
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState(),
        const HomeState(status: HomeStatus.failure, failure: NetworkFailure()),
      ],
    );
  });

  group('refresh', () {
    blocTest<HomeCubit, HomeState>(
      'a failure keeps the old menu on screen',
      setUp: () => answer(const Err(NetworkFailure())),
      build: () => HomeCubit(getMenu),
      seed: () => _loaded,
      act: (cubit) => cubit.refresh(),
      expect: () => [_loaded.copyWith(failure: const NetworkFailure())],
    );

    blocTest<HomeCubit, HomeState>(
      'resets a category tab that is gone after the refresh',
      setUp: () => answer(
        const Ok(
          Menu(
            canteen: sampleCanteen,
            categories: [drinks],
            dishes: [lemonade],
          ),
        ),
      ),
      build: () => HomeCubit(getMenu),
      seed: () => _loaded.copyWith(filter: CategoryDishes(burgers.id)),
      act: (cubit) => cubit.refresh(),
      verify: (cubit) => expect(cubit.state.filter, const AllDishes()),
    );

    blocTest<HomeCubit, HomeState>(
      'without a menu yet it loads from scratch',
      setUp: () => answer(const Ok(sampleMenu)),
      build: () => HomeCubit(getMenu),
      seed: () => const HomeState(
        status: HomeStatus.failure,
        failure: NetworkFailure(),
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [const HomeState(), _loaded],
    );
  });

  group('filters', () {
    test('all dishes by default', () {
      expect(_loaded.visibleDishes, sampleDishes);
    });

    test('popular dishes only', () {
      expect(_loaded.copyWith(filter: const PopularDishes()).visibleDishes, [
        cheeseburger,
      ]);
    });

    test('one category', () {
      expect(
        _loaded.copyWith(filter: CategoryDishes(drinks.id)).visibleDishes,
        [lemonade],
      );
    });

    blocTest<HomeCubit, HomeState>(
      'selectFilter switches the tab',
      build: () => HomeCubit(getMenu),
      seed: () => _loaded,
      act: (cubit) => cubit.selectFilter(const PopularDishes()),
      expect: () => [_loaded.copyWith(filter: const PopularDishes())],
    );
  });
}

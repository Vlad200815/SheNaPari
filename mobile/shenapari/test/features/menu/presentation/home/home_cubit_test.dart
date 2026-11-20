import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari/features/menu/domain/entities/menu.dart';
import 'package:shenapari/features/menu/domain/usecases/get_menu_use_case.dart';
import 'package:shenapari/features/menu/presentation/home/home_cubit.dart';
import 'package:shenapari/features/menu/presentation/home/home_state.dart';
import 'package:shenapari/features/menu/presentation/home/menu_filter.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';
import 'package:shenapari/features/profile/domain/profile_repository.dart';

import '../../menu_samples.dart';

class _MockGetMenuUseCase extends Mock implements GetMenuUseCase {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

final _loaded = HomeState(
  status: HomeStatus.loaded,
  menu: sampleMenu,
  firstName: 'Влад',
);

void main() {
  late _MockGetMenuUseCase getMenu;
  late _MockProfileRepository profile;

  void answer(Result<Menu> result) =>
      when(() => getMenu()).thenAnswer((_) async => result);

  void answerMe(Result<User> result) =>
      when(() => profile.getMe()).thenAnswer((_) async => result);

  setUp(() {
    getMenu = _MockGetMenuUseCase();
    profile = _MockProfileRepository();
    answerMe(const Ok(User(id: '1', role: UserRole.customer, name: 'Влад')));
  });

  HomeCubit build() => HomeCubit(getMenu, profile);

  group('load', () {
    blocTest<HomeCubit, HomeState>(
      'emits [loading, loaded] with the menu and the name',
      setUp: () => answer(Ok(sampleMenu)),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [const HomeState(), _loaded],
    );

    blocTest<HomeCubit, HomeState>(
      'emits failure when there is nothing to show',
      setUp: () => answer(const Err(NetworkFailure())),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState(),
        const HomeState(
          status: HomeStatus.failure,
          failure: NetworkFailure(),
          firstName: 'Влад',
        ),
      ],
    );
  });

  group('greeting', () {
    blocTest<HomeCubit, HomeState>(
      'a failed /me still shows the menu, without a name',
      setUp: () {
        answer(Ok(sampleMenu));
        answerMe(const Err(NetworkFailure()));
      },
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [const HomeState(), _loaded.copyWith(firstName: null)],
    );

    blocTest<HomeCubit, HomeState>(
      'only the first word of the name is used',
      setUp: () {
        answer(Ok(sampleMenu));
        answerMe(
          const Ok(
            User(id: '1', role: UserRole.customer, name: '  Влад Семенюк '),
          ),
        );
      },
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.firstName, 'Влад'),
    );
  });

  group('refresh', () {
    blocTest<HomeCubit, HomeState>(
      'a failure keeps the old menu on screen',
      setUp: () => answer(const Err(NetworkFailure())),
      build: build,
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
      build: build,
      seed: () => _loaded.copyWith(filter: CategoryDishes(burgers.id)),
      act: (cubit) => cubit.refresh(),
      verify: (cubit) => expect(cubit.state.filter, const AllDishes()),
    );

    blocTest<HomeCubit, HomeState>(
      'without a menu yet it loads from scratch',
      setUp: () => answer(Ok(sampleMenu)),
      build: build,
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
      build: build,
      seed: () => _loaded,
      act: (cubit) => cubit.selectFilter(const PopularDishes()),
      expect: () => [_loaded.copyWith(filter: const PopularDishes())],
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/stop_list/domain/entities/stop_list_dish.dart';
import 'package:kitchen/features/stop_list/domain/usecases/get_stop_list_use_case.dart';
import 'package:kitchen/features/stop_list/presentation/stop_list_cubit.dart';
import 'package:kitchen/features/stop_list/presentation/stop_list_state.dart';
import 'package:shenapari_core/result/failure.dart';

import '../../../fakes.dart';

void main() {
  late FakeStopListRepository repository;

  setUp(() {
    repository = FakeStopListRepository(
      dishes: [
        dish(1, 'Борщ український'),
        dish(2, 'Котлета по-київськи', on: false),
        dish(3, 'Круасан', categoryId: 2, on: false),
        dish(4, 'Сирник', categoryId: 2),
      ],
      categories: const [
        DishCategory(id: 1, name: 'Гарячі страви'),
        DishCategory(id: 2, name: 'Випічка'),
      ],
    );
  });

  StopListCubit cubit() =>
      StopListCubit(GetStopListUseCase(repository), repository);

  bool isOn(StopListState state, int id) => state.sections
      .expand((s) => s.dishes)
      .firstWhere((d) => d.id == id)
      .isAvailable;

  test('loads the sections and counts what is switched off', () async {
    final c = cubit();

    await c.load();

    expect(c.state.status, StopListStatus.loaded);
    expect(c.state.sections, hasLength(2));
    expect(c.state.offCount, 2);
  });

  test('a load error', () async {
    repository.failLoad = const ServerFailure('Сервер не відповідає');
    final c = cubit();

    await c.load();

    expect(c.state.status, StopListStatus.failure);
    expect(c.state.failure, isA<ServerFailure>());
  });

  test('«закінчився борщ»: switched off at once', () async {
    final c = cubit();
    await c.load();

    final done = c.toggle(1);
    expect(isOn(c.state, 1), isFalse, reason: 'before the server answers');
    expect(c.state.busy, {1});
    await done;

    expect(isOn(c.state, 1), isFalse);
    expect(c.state.busy, isEmpty);
    expect(repository.calls.last, 'off 1');
  });

  test(
    'the server refused: the switch goes back, the reason is shown',
    () async {
      final c = cubit();
      await c.load();
      repository.fail.add(1);

      await c.toggle(1);

      expect(isOn(c.state, 1), isTrue);
      expect(c.state.failure, isA<ServerFailure>());
    },
  );

  test('«Увімкнути все» switches on only the dishes that are off', () async {
    final c = cubit();
    await c.load();

    await c.enableAll();

    expect(c.state.offCount, 0);
    expect(repository.calls.where((x) => x.startsWith('on')), ['on 2', 'on 3']);
  });

  test('«Увімкнути все» with one failure: that one stays off', () async {
    final c = cubit();
    await c.load();
    repository.fail.add(3);

    await c.enableAll();

    expect(isOn(c.state, 2), isTrue);
    expect(isOn(c.state, 3), isFalse);
    expect(c.state.failure, isNotNull);
  });

  test('search keeps matching dishes, case does not matter', () async {
    final c = cubit();
    await c.load();

    c.search('КРУА');

    expect(c.state.visible, hasLength(1));
    expect(c.state.visible.single.title, 'Випічка');
    expect(c.state.visible.single.dishes.single.name, 'Круасан');
    expect(c.state.offCount, 2, reason: 'the count is for the whole menu');
  });
}

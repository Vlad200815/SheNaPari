import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/stop_list/domain/entities/stop_list_dish.dart';
import 'package:kitchen/features/stop_list/domain/usecases/get_stop_list_use_case.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';

import '../../../fakes.dart';

void main() {
  test(
    'groups dishes by category in the menu order, unknown ones last',
    () async {
      final repository = FakeStopListRepository(
        dishes: [
          dish(1, 'Борщ', categoryId: 2),
          dish(2, 'Чизбургер', categoryId: 1),
          dish(3, 'Вареники', categoryId: 2),
          dish(4, 'Компот', categoryId: 9),
        ],
        categories: const [
          DishCategory(id: 2, name: 'Гарячі страви'),
          DishCategory(id: 1, name: 'Бургери'),
          DishCategory(id: 5, name: 'Салати'),
        ],
      );

      final result = await GetStopListUseCase(repository)();

      final sections = (result as Ok<List<StopListSection>>).value;
      expect(sections.map((s) => s.title), ['Гарячі страви', 'Бургери', null]);
      expect(sections[0].dishes.map((d) => d.name), ['Борщ', 'Вареники']);
      expect(sections[2].dishes.single.name, 'Компот');
    },
  );

  test('a failed request: the failure', () async {
    final repository = FakeStopListRepository()
      ..failLoad = const ServerFailure('Сервер не відповідає');

    final result = await GetStopListUseCase(repository)();

    expect(result, isA<Err<List<StopListSection>>>());
  });
}

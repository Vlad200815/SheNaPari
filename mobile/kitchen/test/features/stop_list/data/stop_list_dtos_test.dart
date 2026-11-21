import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/canteen/data/dto/canteen_dtos.dart';
import 'package:kitchen/features/canteen/domain/canteen_repository.dart';
import 'package:kitchen/features/stop_list/data/dto/stop_list_dtos.dart';
import 'package:kitchen/features/stop_list/domain/entities/stop_list_dish.dart';

void main() {
  test('StaffDishDto → StopListDish', () {
    final dto = StaffDishDto.fromJson({
      'id': 7,
      'categoryId': 2,
      'name': 'Борщ український',
      'isAvailable': false,
    });

    expect(
      dto.toEntity(),
      const StopListDish(
        id: 7,
        categoryId: 2,
        name: 'Борщ український',
        isAvailable: false,
      ),
    );
  });

  test('CategoryDto → DishCategory', () {
    expect(
      CategoryDto.fromJson({'id': 2, 'name': 'Випічка'}).toEntity(),
      const DishCategory(id: 2, name: 'Випічка'),
    );
  });

  test('request bodies match the backend', () {
    expect(const SetAvailabilityDto(isAvailable: true).toJson(), {
      'isAvailable': true,
    });
    expect(const SetAcceptingDto(isAcceptingOrders: false).toJson(), {
      'isAcceptingOrders': false,
    });
  });

  test('CanteenDto → KitchenSwitch: the pause time in local time', () {
    final paused = CanteenDto.fromJson({
      'name': 'Їдальня',
      'isAcceptingOrders': false,
      'pausedAt': '2026-11-21T09:20:00+00:00',
    }).toEntity();
    expect(paused.accepting, isFalse);
    expect(paused.pausedAt, DateTime.utc(2026, 11, 21, 9, 20).toLocal());

    final open = CanteenDto.fromJson({
      'name': 'Їдальня',
      'isAcceptingOrders': true,
    }).toEntity();
    expect(open, const KitchenSwitch(accepting: true));
  });
}

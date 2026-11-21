import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/canteen/data/dto/canteen_dtos.dart';
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
    expect(
      CanteenDto.fromJson({
        'name': 'Їдальня',
        'isAcceptingOrders': true,
      }).isAcceptingOrders,
      isTrue,
    );
  });
}

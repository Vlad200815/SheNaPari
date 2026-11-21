import 'package:shenapari_core/result/result.dart';

import 'entities/stop_list_dish.dart';

abstract interface class StopListRepository {
  /// The whole menu, switched-off dishes included.
  Future<Result<List<StopListDish>>> getDishes();

  /// Menu categories in the menu's order.
  Future<Result<List<DishCategory>>> getCategories();

  /// «Закінчився борщ» (`false`) or «є знову» (`true`).
  Future<Result<StopListDish>> setAvailable(int id, bool available);
}

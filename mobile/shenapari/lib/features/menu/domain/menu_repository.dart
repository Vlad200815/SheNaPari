import '../../../core/result/result.dart';
import 'entities/break_slot.dart';
import 'entities/canteen.dart';
import 'entities/category.dart';
import 'entities/dish.dart';

abstract interface class MenuRepository {
  Future<Result<Canteen>> getCanteen();

  Future<Result<List<Category>>> getCategories();

  /// Only dishes available right now.
  Future<Result<List<Dish>>> getDishes();

  /// One available dish; `menu.dish_not_found` (404) once it is hidden.
  Future<Result<Dish>> getDish(int id);

  /// The nearest break that has not started yet (may be tomorrow), or null
  /// when none is scheduled.
  Future<Result<BreakSlot?>> getNextBreak();
}

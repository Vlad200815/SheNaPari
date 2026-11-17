import '../../../core/result/result.dart';
import 'entities/canteen.dart';
import 'entities/category.dart';
import 'entities/dish.dart';

abstract interface class MenuRepository {
  Future<Result<Canteen>> getCanteen();

  Future<Result<List<Category>>> getCategories();

  /// Only dishes available right now.
  Future<Result<List<Dish>>> getDishes();
}

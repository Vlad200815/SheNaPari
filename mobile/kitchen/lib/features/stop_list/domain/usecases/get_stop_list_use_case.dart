import 'package:shenapari_core/result/result.dart';

import '../entities/stop_list_dish.dart';
import '../stop_list_repository.dart';

/// The stop list grouped like the customers' menu: categories in the
/// menu's order, dishes as the server sorts them (by name).
class GetStopListUseCase {
  GetStopListUseCase(this._repository);

  final StopListRepository _repository;

  Future<Result<List<StopListSection>>> call() async {
    final (dishes, categories) = await (
      _repository.getDishes(),
      _repository.getCategories(),
    ).wait;
    return switch ((dishes, categories)) {
      (Err(:final failure), _) || (_, Err(:final failure)) => Err(failure),
      (Ok(value: final dishes), Ok(value: final categories)) => Ok(
        _group(dishes, categories),
      ),
    };
  }

  static List<StopListSection> _group(
    List<StopListDish> dishes,
    List<DishCategory> categories,
  ) {
    final known = {for (final c in categories) c.id};
    return [
      for (final category in categories)
        if (dishes.where((d) => d.categoryId == category.id).toList()
            case final inCategory when inCategory.isNotEmpty)
          StopListSection(title: category.name, dishes: inCategory),
      if (dishes.where((d) => !known.contains(d.categoryId)).toList()
          case final other when other.isNotEmpty)
        StopListSection(title: null, dishes: other),
    ];
  }
}

import 'package:shenapari_core/result/result.dart';
import '../entities/menu.dart';
import '../menu_repository.dart';

/// Loads the canteen, categories, dishes and the next break in parallel and
/// puts them together. Any failure fails the whole menu: half a menu is not
/// useful.
class GetMenuUseCase {
  GetMenuUseCase(this._menu);

  final MenuRepository _menu;

  Future<Result<Menu>> call() async {
    final results = await (
      _menu.getCanteen(),
      _menu.getCategories(),
      _menu.getDishes(),
      _menu.getNextBreak(),
    ).wait;

    switch (results) {
      case (
        Ok(value: final canteen),
        Ok(value: final categories),
        Ok(value: final dishes),
        Ok(value: final nextBreak),
      ):
        final used = {for (final dish in dishes) dish.categoryId};
        return Ok(
          Menu(
            canteen: canteen,
            // A category whose dishes are all hidden would show an empty tab.
            categories: [
              for (final category in categories)
                if (used.contains(category.id)) category,
            ],
            dishes: dishes,
            nextBreak: nextBreak,
          ),
        );
      case (Err(:final failure), _, _, _) ||
          (_, Err(:final failure), _, _) ||
          (_, _, Err(:final failure), _) ||
          (_, _, _, Err(:final failure)):
        return Err(failure);
    }
  }
}

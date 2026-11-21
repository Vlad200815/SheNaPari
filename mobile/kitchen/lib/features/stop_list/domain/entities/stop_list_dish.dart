import 'package:equatable/equatable.dart';

/// A dish on the stop list: switched off, it disappears from the
/// customers' menu at once.
class StopListDish extends Equatable {
  const StopListDish({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.isAvailable,
  });

  final int id;
  final int categoryId;
  final String name;
  final bool isAvailable;

  StopListDish withAvailable(bool available) => StopListDish(
    id: id,
    categoryId: categoryId,
    name: name,
    isAvailable: available,
  );

  @override
  List<Object?> get props => [id, categoryId, name, isAvailable];
}

class DishCategory extends Equatable {
  const DishCategory({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// One category's dishes; [title] is null for dishes whose category the
/// menu no longer lists (shown last, as «Інше»).
class StopListSection extends Equatable {
  const StopListSection({required this.title, required this.dishes});

  final String? title;
  final List<StopListDish> dishes;

  @override
  List<Object?> get props => [title, dishes];
}

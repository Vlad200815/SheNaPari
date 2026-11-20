import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/menu.dart';
import 'menu_filter.dart';

part 'home_state.freezed.dart';

/// `failure` means the first load failed and there is nothing to show.
/// A failed pull-to-refresh keeps `loaded` and the old menu, and only sets
/// [HomeState.failure] for a snack bar.
enum HomeStatus { loading, loaded, failure }

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default(HomeStatus.loading) HomeStatus status,
    Menu? menu,
    @Default(AllDishes()) MenuFilter filter,
    Failure? failure,

    /// For the greeting; null if `/me` failed or the name is empty.
    String? firstName,
  }) = _HomeState;

  List<Dish> get visibleDishes => [
    for (final dish in menu?.dishes ?? const <Dish>[])
      if (filter.matches(dish)) dish,
  ];
}

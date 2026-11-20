import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shenapari_core/result/failure.dart';
import '../../domain/entities/break_slot.dart';
import '../../domain/entities/dish.dart';

part 'dish_state.freezed.dart';

enum DishStatus { loading, loaded, failure }

@freezed
abstract class DishState with _$DishState {
  const DishState._();

  const factory DishState({
    @Default(DishStatus.loading) DishStatus status,
    Dish? dish,

    /// For "забереш на перерві о 11:40"; null if unknown or none.
    BreakSlot? nextBreak,

    /// Portions to add, chosen with the stepper.
    @Default(1) int quantity,
    Failure? failure,
  }) = _DishState;

  int get totalKopecks => (dish?.priceKopecks ?? 0) * quantity;
}

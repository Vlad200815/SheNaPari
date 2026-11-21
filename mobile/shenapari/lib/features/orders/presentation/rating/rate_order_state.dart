import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenapari_core/result/failure.dart';

import '../../domain/entities/order.dart';

part 'rate_order_state.freezed.dart';

/// `sent`: the sheet shows «Дякуємо!» and closes itself.
enum RateOrderStatus { editing, sending, sent }

@freezed
abstract class RateOrderState with _$RateOrderState {
  const RateOrderState._();

  const factory RateOrderState({
    @Default(RateOrderStatus.editing) RateOrderStatus status,

    /// 0 until a star is tapped.
    @Default(0) int stars,

    /// In the order they were tapped.
    @Default(<RatingTag>[]) List<RatingTag> tags,
    @Default('') String comment,
    @Default(false) bool commentOpen,

    /// What the server saved, once sent.
    OrderRating? rating,
    Failure? failure,
  }) = _RateOrderState;

  /// The tags this many stars offers (praise for 4–5, complaints for 1–3).
  List<RatingTag> get offered => RatingTag.offeredFor(stars);

  bool get canSend => stars > 0 && status == RateOrderStatus.editing;
}

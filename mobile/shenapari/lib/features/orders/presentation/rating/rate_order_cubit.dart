import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/result/result.dart';

import '../../domain/entities/order.dart';
import '../../domain/orders_repository.dart';
import 'rate_order_state.dart';

/// The rating sheet: stars (maybe already tapped on the home card), tags
/// that fit the score, an optional comment, «Надіслати».
class RateOrderCubit extends Cubit<RateOrderState> {
  RateOrderCubit(
    this._orders, {
    required this.orderId,
    int initialStars = 0,
    OrderRating? existing,
  }) : super(
         existing == null
             ? RateOrderState(stars: initialStars.clamp(0, 5))
             : RateOrderState(
                 stars: existing.stars,
                 tags: existing.tags,
                 comment: existing.comment ?? '',
                 commentOpen: existing.comment != null,
               ),
       );

  final OrdersRepository _orders;
  final String orderId;

  /// The server's limit.
  static const maxComment = 500;

  void setStars(int stars) {
    if (state.status != RateOrderStatus.editing) return;
    final sameSide = (stars >= 4) == (state.stars >= 4);
    emit(
      state.copyWith(
        stars: stars.clamp(1, 5),
        tags: sameSide ? state.tags : const [],
        failure: null,
      ),
    );
  }

  void toggleTag(RatingTag tag) {
    if (!state.offered.contains(tag)) return;
    emit(
      state.copyWith(
        tags: state.tags.contains(tag)
            ? [
                for (final t in state.tags)
                  if (t != tag) t,
              ]
            : [...state.tags, tag],
      ),
    );
  }

  void openComment() => emit(state.copyWith(commentOpen: true));

  void setComment(String text) => emit(
    state.copyWith(
      comment: text.length > maxComment ? text.substring(0, maxComment) : text,
    ),
  );

  Future<void> send() async {
    if (!state.canSend) return;
    emit(state.copyWith(status: RateOrderStatus.sending, failure: null));
    final comment = state.comment.trim();
    final result = await _orders.rate(
      orderId,
      stars: state.stars,
      tags: state.tags,
      comment: comment.isEmpty ? null : comment,
    );
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final rating) => state.copyWith(
        status: RateOrderStatus.sent,
        rating: rating,
      ),
      Err(:final failure) => state.copyWith(
        status: RateOrderStatus.editing,
        failure: failure,
      ),
    });
  }
}

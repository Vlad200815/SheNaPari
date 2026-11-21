import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari_core/result/result.dart';

import '../../domain/entities/order.dart';
import '../../domain/orders_repository.dart';

/// The «Як вам №36?» card on the home screen; null: no card. A failed load
/// just shows no card: it is a nicety, not the menu.
class RatingPromptCubit extends Cubit<RatingPrompt?> {
  RatingPromptCubit(this._orders) : super(null);

  final OrdersRepository _orders;

  Future<void> load() async {
    if (await _orders.getRatingPrompt() case Ok(value: final prompt)) {
      if (!isClosed) emit(prompt);
    }
  }

  /// «Не зараз»: gone at once; the server remembers it.
  Future<void> dismiss() async {
    final prompt = state;
    if (prompt == null) return;
    emit(null);
    await _orders.dismissRatingPrompt(prompt.orderId);
  }

  /// The sheet saved a rating for [orderId].
  void rated(String orderId) {
    if (state?.orderId == orderId) emit(null);
  }
}

import 'package:equatable/equatable.dart';

/// The quick marks under the stars. The server stores codes; 4–5 stars
/// offer the good ones, 1–3 the complaints.
enum RatingTag {
  tasty,
  fast,
  hot,
  bigPortion,
  noQueue,
  cold,
  slow,
  smallPortion,
  wrongOrder,
  notTasty,
  unknown;

  static const positive = [tasty, fast, hot, bigPortion, noQueue];
  static const negative = [cold, slow, smallPortion, wrongOrder, notTasty];

  /// What a rating of [stars] offers.
  static List<RatingTag> offeredFor(int stars) =>
      stars >= 4 ? positive : negative;

  bool get isPositive => positive.contains(this);
}

/// The customer's rating of a picked-up order.
class OrderRating extends Equatable {
  const OrderRating({
    required this.stars,
    this.tags = const [],
    this.comment,
    this.updatedAt,
  });

  /// 1–5.
  final int stars;
  final List<RatingTag> tags;
  final String? comment;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [stars, tags, comment, updatedAt];
}

/// The «Як вам №36?» card on the home screen.
class RatingPrompt extends Equatable {
  const RatingPrompt({
    required this.orderId,
    required this.number,
    required this.items,
    required this.pickedUpAt,
  });

  final String orderId;
  final int number;

  /// Dish names, as ordered.
  final List<String> items;
  final DateTime pickedUpAt;

  @override
  List<Object?> get props => [orderId, number, items, pickedUpAt];
}

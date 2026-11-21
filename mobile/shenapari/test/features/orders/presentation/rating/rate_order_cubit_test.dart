import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/presentation/rating/rate_order_cubit.dart';
import 'package:shenapari/features/orders/presentation/rating/rate_order_state.dart';
import 'package:shenapari_core/result/failure.dart';

import '../../../../fakes.dart';

void main() {
  late FakeOrdersRepository orders;

  setUp(() => orders = FakeOrdersRepository());

  RateOrderCubit cubit({int stars = 0, OrderRating? existing}) =>
      RateOrderCubit(
        orders,
        orderId: 'o36',
        initialStars: stars,
        existing: existing,
      );

  test('starts with the star tapped on the card', () {
    final c = cubit(stars: 4);

    expect(c.state.stars, 4);
    expect(c.state.offered, RatingTag.positive);
    expect(c.state.canSend, isTrue);
  });

  test('no stars yet: nothing to send', () async {
    final c = cubit();

    await c.send();

    expect(c.state.canSend, isFalse);
    expect(orders.ratings, isEmpty);
  });

  test('praise and complaints do not mix: switching sides clears the tags', () {
    final c = cubit(stars: 5)
      ..toggleTag(RatingTag.tasty)
      ..toggleTag(RatingTag.fast);

    c.setStars(4);
    expect(c.state.tags, [
      RatingTag.tasty,
      RatingTag.fast,
    ], reason: 'same side');

    c.setStars(2);
    expect(c.state.tags, isEmpty);
    expect(c.state.offered, RatingTag.negative);
  });

  test('a tag tapped twice is off again', () {
    final c = cubit(stars: 2)
      ..toggleTag(RatingTag.cold)
      ..toggleTag(RatingTag.cold);

    expect(c.state.tags, isEmpty);
  });

  test('sends stars, tags and the trimmed comment', () async {
    final c = cubit(stars: 2)
      ..toggleTag(RatingTag.cold)
      ..openComment()
      ..setComment('  Бургер охолов  ');

    await c.send();

    expect(c.state.status, RateOrderStatus.sent);
    expect(
      orders.ratings['o36'],
      const OrderRating(
        stars: 2,
        tags: [RatingTag.cold],
        comment: 'Бургер охолов',
      ),
    );
  });

  test('an empty comment is sent as none', () async {
    final c = cubit(stars: 5)..setComment('   ');

    await c.send();

    expect(orders.ratings['o36']?.comment, isNull);
  });

  test('the server refused: back to editing, the reason is shown', () async {
    orders.failRating = const ConflictFailure(
      'Оцінити замовлення можна протягом 3 днів',
      code: 'rating.window_closed',
    );
    final c = cubit(stars: 5);

    await c.send();

    expect(c.state.status, RateOrderStatus.editing);
    expect(c.state.failure?.code, 'rating.window_closed');
  });

  test('changing a rating starts from what was given', () {
    final c = cubit(
      existing: const OrderRating(
        stars: 2,
        tags: [RatingTag.slow],
        comment: 'Довго',
      ),
    );

    expect(c.state.stars, 2);
    expect(c.state.tags, [RatingTag.slow]);
    expect(c.state.comment, 'Довго');
    expect(c.state.commentOpen, isTrue);
  });
}

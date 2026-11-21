import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/orders/data/dto/order_dtos.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';

/// `data` of `POST /orders` as the backend serializes it.
const _json = {
  'id': '3f2a6c1e-0000-4000-8000-000000000001',
  'number': 7,
  'status': 'Paid',
  'total': 212.5,
  'createdAt': '2026-11-17T09:05:00+00:00',
  'breakSlot': {
    'id': 4,
    'startsAt': '2026-11-17T09:40:00+00:00',
    'endsAt': '2026-11-17T10:00:00+00:00',
  },
  'estimatedReadyAt': null,
  'readyAt': null,
  'paymentProvider': 'GooglePay',
  'items': [
    {'dishId': 1, 'name': 'Чизбургер', 'quantity': 2, 'unitPrice': 95},
    {'dishId': 9, 'name': 'Лимонад', 'quantity': 1, 'unitPrice': 22.5},
  ],
  'history': [
    {'status': 'Paid', 'at': '2026-11-17T09:05:00+00:00', 'reason': null},
  ],
  'pickupToken': null,
};

void main() {
  test('reads a placed order', () {
    final order = OrderDto.fromJson(_json).toEntity();

    expect(order.number, 7);
    expect(order.status, OrderStatus.paid);
    expect(order.totalKopecks, 21250);
    expect(order.breakSlot!.id, 4);
    expect(
      order.breakSlot!.startsAt,
      DateTime.utc(2026, 11, 17, 9, 40).toLocal(),
    );
    expect(order.items, const [
      OrderItem(
        dishId: 1,
        name: 'Чизбургер',
        quantity: 2,
        unitPriceKopecks: 9500,
      ),
      OrderItem(
        dishId: 9,
        name: 'Лимонад',
        quantity: 1,
        unitPriceKopecks: 2250,
      ),
    ]);
  });

  test('«as soon as possible» has no break', () {
    final order = OrderDto.fromJson({..._json, 'breakSlot': null}).toEntity();

    expect(order.breakSlot, isNull);
  });

  test('statuses come in PascalCase; unknown ones do not crash', () {
    expect(OrderDto.parseStatus('PickedUp'), OrderStatus.pickedUp);
    expect(OrderDto.parseStatus('NotPickedUp'), OrderStatus.notPickedUp);
    expect(OrderDto.parseStatus('Refunded'), OrderStatus.unknown);
  });

  test('the request matches the backend contract', () {
    const dto = CreateOrderDto(
      breakSlotId: null,
      paymentProvider: 'ApplePay',
      items: [CreateOrderItemDto(dishId: 1, quantity: 2)],
    );

    expect(dto.toJson(), {
      'breakSlotId': null,
      'paymentProvider': 'ApplePay',
      'items': [
        {'dishId': 1, 'quantity': 2},
      ],
    });
    expect(OrderDto.providerName(PaymentProvider.googlePay), 'GooglePay');
  });

  test('history and the pickup token of a ready order', () {
    final order = OrderDto.fromJson({
      ..._json,
      'status': 'Ready',
      'history': [
        {'status': 'Paid', 'at': '2026-11-17T09:05:00+00:00', 'reason': null},
        {'status': 'Ready', 'at': '2026-11-17T09:25:00+00:00', 'reason': null},
      ],
      'pickupToken': 'b7c1d2e3-0000-4000-8000-000000000009',
    }).toEntity();

    expect(order.pickupToken, 'b7c1d2e3-0000-4000-8000-000000000009');
    expect(
      order.reachedAt(OrderStatus.ready),
      DateTime.utc(2026, 11, 17, 9, 25).toLocal(),
    );
    expect(order.reachedAt(OrderStatus.cooking), isNull);
    expect(order.isActive, isTrue);
    expect(order.canCancel, isFalse);
  });

  test('a rated order: stars, tag codes, comment and until when', () {
    final order = OrderDto.fromJson({
      ..._json,
      'status': 'PickedUp',
      'rating': {
        'stars': 5,
        'tags': ['tasty', 'big_portion', 'new_tag_from_the_future'],
        'comment': 'Найкращий бургер',
        'updatedAt': '2026-11-21T10:00:00+00:00',
      },
      'rateUntil': '2026-11-24T09:42:00+00:00',
    }).toEntity();

    expect(order.rating!.stars, 5);
    expect(order.rating!.tags, [RatingTag.tasty, RatingTag.bigPortion]);
    expect(order.rating!.comment, 'Найкращий бургер');
    expect(order.rateUntil, DateTime.utc(2026, 11, 24, 9, 42).toLocal());
    expect(order.canRate, isTrue);
  });

  test('an order that can no longer be rated', () {
    final order = OrderDto.fromJson(_json).toEntity();

    expect(order.rating, isNull);
    expect(order.canRate, isFalse);
  });

  test('tag codes both ways', () {
    for (final tag in RatingTag.values.where((t) => t != RatingTag.unknown)) {
      expect(parseRatingTag(ratingTagCode(tag)), tag);
    }
    expect(ratingTagCode(RatingTag.smallPortion), 'small_portion');
    expect(
      const RateOrderDto(stars: 2, tags: ['cold'], comment: null).toJson(),
      {
        'stars': 2,
        'tags': ['cold'],
        'comment': null,
      },
    );
  });

  test('the home card prompt', () {
    final prompt = RatingPromptDto.fromJson({
      'orderId': 'o36',
      'number': 36,
      'items': ['Бургер з куркою', 'Компот'],
      'pickedUpAt': '2026-11-21T09:42:00+00:00',
    }).toEntity();

    expect(prompt.number, 36);
    expect(prompt.items, ['Бургер з куркою', 'Компот']);
    expect(prompt.pickedUpAt, DateTime.utc(2026, 11, 21, 9, 42).toLocal());
  });
}

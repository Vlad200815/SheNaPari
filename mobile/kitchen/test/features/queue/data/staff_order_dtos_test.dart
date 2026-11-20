import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/queue/data/dto/staff_order_dtos.dart';
import 'package:kitchen/features/queue/domain/entities/kitchen_order.dart';

void main() {
  test('reads an order of GET /staff/orders', () {
    final order = StaffOrderDto.fromJson({
      'id': 'a1',
      'number': 41,
      'status': 'Accepted',
      'total': 110,
      'customerName': 'Влад',
      'createdAt': '2026-11-20T09:12:00Z',
      'breakSlot': {
        'id': 3,
        'startsAt': '2026-11-20T09:40:00Z',
        'endsAt': '2026-11-20T10:00:00Z',
      },
      'estimatedReadyAt': '2026-11-20T09:35:00Z',
      'readyAt': null,
      'items': [
        {
          'dishId': 10,
          'name': 'Борщ український',
          'quantity': 2,
          'unitPrice': 55,
        },
      ],
      'history': [],
    }).toEntity();

    expect(order.number, 41);
    expect(order.status, OrderStatus.accepted);
    expect(order.column, QueueColumn.cooking, reason: 'accepted = cooking');
    expect(order.customerName, 'Влад');
    expect(order.breakStartsAt, DateTime.utc(2026, 11, 20, 9, 40).toLocal());
    expect(order.isAsap, isFalse);
    expect(
      order.items.single,
      const KitchenOrderItem(name: 'Борщ український', quantity: 2),
    );
  });

  test('no break: as soon as possible, needed from the moment it was paid', () {
    final order = StaffOrderDto.fromJson({
      'id': 'a2',
      'number': 42,
      'status': 'Paid',
      'createdAt': '2026-11-20T09:20:00Z',
      'items': [],
    }).toEntity();

    expect(order.isAsap, isTrue);
    expect(order.neededBy, order.createdAt);
    expect(order.column, QueueColumn.fresh);
  });

  test('a status the app does not know stays off the board', () {
    final order = StaffOrderDto.fromJson({
      'id': 'a3',
      'number': 43,
      'status': 'Teleported',
      'createdAt': '2026-11-20T09:20:00Z',
      'items': [],
    }).toEntity();

    expect(order.status, OrderStatus.unknown);
    expect(order.column, isNull);
  });

  test('the status is sent the way the API expects it', () {
    expect(const UpdateStatusDto(status: 'PickedUp').toJson(), {
      'status': 'PickedUp',
    });
  });
}

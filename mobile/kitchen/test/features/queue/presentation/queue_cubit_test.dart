import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/queue/domain/entities/kitchen_order.dart';
import 'package:kitchen/features/queue/presentation/queue_cubit.dart';
import 'package:kitchen/features/queue/presentation/queue_state.dart';
import 'package:shenapari_core/result/failure.dart';

import '../../../fakes.dart';

void main() {
  final now = DateTime(2026, 11, 20, 11, 30);
  final break1140 = DateTime(2026, 11, 20, 11, 40);
  final break1320 = DateTime(2026, 11, 20, 13, 20);
  late FakeQueueRepository repository;
  late FakeOrderEvents events;
  late FakeNewOrderAlert alert;

  setUp(() {
    repository = FakeQueueRepository([
      order(43, breakAt: break1320, minute: 25),
      order(41, breakAt: break1140, minute: 28),
      order(42, minute: 29), // as soon as possible
      order(38, status: OrderStatus.cooking, breakAt: break1140, minute: 10),
      order(36, status: OrderStatus.ready, minute: 5, name: 'Влад'),
    ]);
    events = FakeOrderEvents();
    alert = FakeNewOrderAlert();
  });

  QueueCubit cubit() => QueueCubit(repository, events, alert, clock: () => now);
  List<int> numbers(List<KitchenOrder> list) => [
    for (final o in list) o.number,
  ];

  test('three columns, the one needed soonest on top', () async {
    final c = cubit();
    await c.load();

    expect(numbers(c.state.column(QueueColumn.fresh)), [
      42,
      41,
      43,
    ], reason: 'ASAP first, then the 11:40 break, then 13:20');
    expect(numbers(c.state.column(QueueColumn.cooking)), [38]);
    expect(numbers(c.state.column(QueueColumn.ready)), [36]);
    expect(alert.plays, 0, reason: 'no chime for what was already there');
    await c.close();
  });

  test('filters: as soon as possible, or one break', () async {
    final c = cubit();
    await c.load();
    expect(c.state.asapCount, 2);
    expect(c.state.breaks, [(break1140, 2), (break1320, 1)]);

    c.selectFilter(const AsapOrders());
    expect(numbers(c.state.column(QueueColumn.fresh)), [42]);
    expect(numbers(c.state.column(QueueColumn.ready)), [36]);

    c.selectFilter(BreakOrders(break1140));
    expect(numbers(c.state.column(QueueColumn.fresh)), [41]);
    expect(numbers(c.state.column(QueueColumn.cooking)), [38]);
    expect(c.state.count(QueueColumn.fresh), 3, reason: 'counts ignore it');
    await c.close();
  });

  test('a new order chimes and shows its number', () async {
    final c = cubit();
    await c.load();

    repository.orders = [...repository.orders, order(44, minute: 30)];
    await c.refresh();

    expect(alert.plays, 1);
    expect(c.state.arrived, [44]);
    expect(c.state.arrivals, 1);

    await c.refresh();
    expect(alert.plays, 1, reason: 'not again for the same order');
    await c.close();
  });

  test('«Прийняти · 15 хв» moves it to cooking', () async {
    final c = cubit();
    await c.load();

    await c.accept('o41', minutes: 15);

    expect(repository.calls, contains('accept o41 15'));
    expect(numbers(c.state.column(QueueColumn.cooking)), [38, 41]);
    expect(c.state.busy, isEmpty);
    await c.close();
  });

  test('«Готово» and «Видати без QR»', () async {
    final c = cubit();
    await c.load();

    await c.markReady('o38');
    await c.handOver('o36');

    expect(repository.calls, containsAllInOrder(['ready o38', 'pickedUp o36']));
    expect(numbers(c.state.column(QueueColumn.ready)), [38]);
    await c.close();
  });

  test('a failed action keeps the board and says why', () async {
    final c = cubit();
    await c.load();
    repository.failNext = const ConflictFailure(
      'Замовлення вже скасовано',
      code: 'order.invalid_transition',
    );

    await c.markReady('o38');

    expect(c.state.failure, isA<ConflictFailure>());
    expect(c.state.status, QueueStatus.loaded);
    expect(numbers(c.state.column(QueueColumn.cooking)), [38]);
    await c.close();
  });

  test('an order event reloads the board (bursts at once)', () async {
    final c = cubit();
    await c.load();
    final gets = repository.calls.where((x) => x == 'get').length;

    repository.orders = [...repository.orders, order(45, minute: 30)];
    events
      ..changed('o45')
      ..changed('o45');
    await Future<void>.delayed(QueueCubit.debounce * 2);

    expect(repository.calls.where((x) => x == 'get').length, gets + 1);
    expect(c.state.count(QueueColumn.fresh), 4);
    await c.close();
  });

  test('«Скасувати» with a reason takes it off the board', () async {
    final c = cubit();
    await c.load();

    await c.cancel('o38', reason: 'Закінчились продукти');

    expect(repository.calls, contains('cancelled o38: Закінчились продукти'));
    expect(c.state.count(QueueColumn.cooking), 0);
    await c.close();
  });
}

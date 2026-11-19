import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/domain/entities/order_history.dart';
import 'package:shenapari/features/orders/presentation/orders/order_history_cubit.dart';

import '../../../../fakes.dart';

/// Finished order #[number], placed on [day] November at noon.
Order finished(int number, int day, OrderStatus status, {int month = 11}) =>
    Order(
      id: 'order-$number',
      number: number,
      status: status,
      totalKopecks: 10000,
      createdAt: DateTime(2026, month, day, 12),
      items: const [],
    );

void main() {
  late FakeOrdersRepository repository;
  late FakeOrderEvents events;

  setUp(() {
    repository = FakeOrdersRepository()
      ..historyPageSize = 2
      ..orders.addAll([
        finished(5, 18, OrderStatus.pickedUp),
        finished(4, 17, OrderStatus.cancelled),
        finished(3, 16, OrderStatus.notPickedUp),
        finished(2, 30, OrderStatus.pickedUp, month: 10),
        finished(1, 29, OrderStatus.pickedUp, month: 10),
      ]);
    events = FakeOrderEvents();
  });

  List<int> numbers(OrderHistoryState state) => [
    for (final order in state.orders) order.number,
  ];

  test('the first page comes with the months of the whole history', () async {
    final cubit = OrderHistoryCubit(repository, events);

    await cubit.load();

    expect(cubit.state.status, OrderHistoryStatus.loaded);
    expect(numbers(cubit.state), [5, 4]);
    expect(cubit.state.hasMore, isTrue);
    expect(cubit.state.months, const [
      OrderMonth(year: 2026, month: 11, count: 3, spentKopecks: 20000),
      OrderMonth(year: 2026, month: 10, count: 2, spentKopecks: 20000),
    ]);
  });

  test('the next pages continue before the last order shown', () async {
    final cubit = OrderHistoryCubit(repository, events);
    await cubit.load();

    await cubit.loadMore();
    await cubit.loadMore();
    await cubit.loadMore(); // nothing left: no request

    expect(numbers(cubit.state), [5, 4, 3, 2, 1]);
    expect(cubit.state.hasMore, isFalse);
    expect(repository.historyRequests.map((r) => r.before), [
      null,
      DateTime(2026, 11, 17, 12),
      DateTime(2026, 10, 30, 12),
    ]);
  });

  test('a filter starts over with that status only', () async {
    final cubit = OrderHistoryCubit(repository, events);
    await cubit.load();
    await cubit.loadMore();

    await cubit.setFilter(OrderStatus.cancelled);

    expect(cubit.state.filter, OrderStatus.cancelled);
    expect(numbers(cubit.state), [4]);
    expect(cubit.state.hasMore, isFalse);
    expect(repository.historyRequests.last.status, OrderStatus.cancelled);
  });

  test('an answer for the old filter that comes late is dropped', () async {
    final slow = _SlowFirst(repository);
    final cubit = OrderHistoryCubit(slow, events);
    final first = cubit.load(); // all orders, answered last

    await cubit.setFilter(OrderStatus.notPickedUp);
    slow.release();
    await first;

    expect(numbers(cubit.state), [3]);
  });

  test('reloads by itself when an order changes', () async {
    final cubit = OrderHistoryCubit(repository, events);
    await cubit.load();

    repository.orders.insert(0, finished(6, 19, OrderStatus.pickedUp));
    events.changed('order-6');
    await Future<void>.delayed(Duration.zero);

    expect(numbers(cubit.state), [6, 5]);
    await cubit.close();
  });

  test('a failed next page keeps the list and says why', () async {
    final failing = _FailingAfterFirst(repository);
    final cubit = OrderHistoryCubit(failing, events);
    await cubit.load();

    await cubit.loadMore();

    expect(numbers(cubit.state), [5, 4]);
    expect(cubit.state.loadingMore, isFalse);
    expect(cubit.state.failure, const NetworkFailure());
  });

  test('a failed first page shows the error', () async {
    final cubit = OrderHistoryCubit(
      _FailingAfterFirst(repository, ok: 0),
      events,
    );

    await cubit.load();

    expect(cubit.state.status, OrderHistoryStatus.failure);
    expect(cubit.state.failure, const NetworkFailure());
  });
}

class _FailingAfterFirst extends FakeOrdersRepository {
  _FailingAfterFirst(this._inner, {this.ok = 1});

  final FakeOrdersRepository _inner;
  final int ok;
  var _calls = 0;

  @override
  Future<Result<OrderHistoryPage>> getHistory({
    OrderStatus? status,
    DateTime? before,
  }) async => _calls++ < ok
      ? _inner.getHistory(status: status, before: before)
      : const Err(NetworkFailure());
}

/// The first request waits until [release]; the rest answer at once.
class _SlowFirst extends FakeOrdersRepository {
  _SlowFirst(this._inner);

  final FakeOrdersRepository _inner;
  final _gate = Completer<void>();
  var _calls = 0;

  void release() => _gate.complete();

  @override
  Future<Result<OrderHistoryPage>> getHistory({
    OrderStatus? status,
    DateTime? before,
  }) async {
    if (_calls++ == 0) await _gate.future;
    return _inner.getHistory(status: status, before: before);
  }
}

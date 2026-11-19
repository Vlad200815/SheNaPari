import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/presentation/orders/orders_cubit.dart';

import '../../../../fakes.dart';
import '../../../menu/menu_samples.dart';

void main() {
  late FakeOrdersRepository repository;
  late FakeOrderEvents events;

  setUp(() async {
    repository = FakeOrdersRepository();
    events = FakeOrderEvents();
    await repository.placeOrder(
      items: const [CartItem(dish: cheeseburger, quantity: 1)],
      breakSlotId: null,
      provider: PaymentProvider.applePay,
    );
  });

  test('loads only the active orders', () async {
    repository.kitchen('order-7', OrderStatus.pickedUp);
    final cubit = OrdersCubit(repository, events);

    await cubit.load();

    expect(cubit.state.orders, isEmpty);
    expect(cubit.state.forPickup, isEmpty);
  });

  test('reloads by itself when the kitchen changes a status', () async {
    final cubit = OrdersCubit(repository, events);
    await cubit.load();
    expect(cubit.state.forPickup.single.status, OrderStatus.paid);

    repository.kitchen('order-7', OrderStatus.ready, pickupToken: 't');
    events.changed('order-7');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.forPickup.single.status, OrderStatus.ready);
    await cubit.close();
  });

  test('«Мій QR»: ready orders first, longest-waiting on top', () {
    Order order(
      String id,
      OrderStatus status, {
      required int minute,
      int? readyMinute,
    }) => Order(
      id: id,
      number: 1,
      status: status,
      totalKopecks: 0,
      createdAt: DateTime(2026, 11, 18, 11, minute),
      readyAt: readyMinute == null
          ? null
          : DateTime(2026, 11, 18, 11, readyMinute),
      items: const [],
    );
    final state = OrdersState(
      status: OrdersStatus.loaded,
      orders: [
        order('cooking-new', OrderStatus.cooking, minute: 30),
        order('ready-late', OrderStatus.ready, minute: 5, readyMinute: 25),
        order('paid-old', OrderStatus.paid, minute: 10),
        order('ready-early', OrderStatus.ready, minute: 20, readyMinute: 22),
        order('done', OrderStatus.pickedUp, minute: 1),
      ],
    );

    expect(
      [for (final o in state.forPickup) o.id],
      ['ready-early', 'ready-late', 'paid-old', 'cooking-new'],
    );
    expect(state.readyCount, 2);
  });

  test('a failed refresh keeps the list', () async {
    final cubit = OrdersCubit(_FailingAfterFirst(repository), events);
    await cubit.load();

    await cubit.refresh();

    expect(cubit.state.status, OrdersStatus.loaded);
    expect(cubit.state.orders, hasLength(1));
    expect(cubit.state.failure, const NetworkFailure());
  });
}

class _FailingAfterFirst extends FakeOrdersRepository {
  _FailingAfterFirst(this._inner);

  final FakeOrdersRepository _inner;
  var _calls = 0;

  @override
  Future<Result<List<Order>>> getActiveOrders() async =>
      _calls++ == 0 ? _inner.getActiveOrders() : const Err(NetworkFailure());
}

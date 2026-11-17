import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/presentation/order/order_cubit.dart';

import '../../../../fakes.dart';
import '../../../menu/menu_samples.dart';

void main() {
  late FakeOrdersRepository repository;
  late FakeOrderEvents events;
  late OrderCubit cubit;

  setUp(() async {
    repository = FakeOrdersRepository();
    events = FakeOrderEvents();
    await repository.placeOrder(
      items: const [CartItem(dish: cheeseburger, quantity: 2)],
      breakSlotId: null,
      provider: PaymentProvider.googlePay,
    );
    cubit = OrderCubit(repository, events, orderId: 'order-7');
  });

  tearDown(() => cubit.close());

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('loads the order', () async {
    await cubit.load();

    expect(cubit.state.status, OrderLoadStatus.loaded);
    expect(cubit.state.order!.number, 7);
  });

  test('reloads on its own event and on a reconnect, not on others', () async {
    await cubit.load();

    repository.kitchen('order-7', OrderStatus.cooking);
    events.changed('another-order');
    await flush();
    expect(cubit.state.order!.status, OrderStatus.paid);

    events.changed('order-7');
    await flush();
    expect(cubit.state.order!.status, OrderStatus.cooking);

    repository.kitchen('order-7', OrderStatus.ready, pickupToken: 't');
    events.changed(null); // reconnected: anything may have changed
    await flush();
    expect(cubit.state.order!.pickupToken, 't');
  });

  test('cancel shows the cancelled order', () async {
    await cubit.load();

    await cubit.cancel();

    expect(cubit.state.order!.status, OrderStatus.cancelled);
    expect(cubit.state.cancelling, isFalse);
  });

  test('a refused cancel shows why and the fresh status', () async {
    final refusing = _RefusingCancel(repository);
    final cubit = OrderCubit(refusing, events, orderId: 'order-7');
    await cubit.load();

    await cubit.cancel();

    expect(cubit.state.failure?.code, 'order.cannot_cancel');
    expect(cubit.state.order!.status, OrderStatus.cooking);
    await cubit.close();
  });

  test('no cancel once cooking started', () async {
    repository.kitchen('order-7', OrderStatus.cooking);
    await cubit.load();

    await cubit.cancel();

    expect(cubit.state.order!.status, OrderStatus.cooking);
  });
}

/// The kitchen started cooking just before the customer pressed «Скасувати».
class _RefusingCancel extends FakeOrdersRepository {
  _RefusingCancel(this._inner);

  final FakeOrdersRepository _inner;

  @override
  Future<Result<Order>> getOrder(String id) => _inner.getOrder(id);

  @override
  Future<Result<Order>> cancel(String id) async {
    _inner.kitchen(id, OrderStatus.cooking);
    return const Err(
      ConflictFailure(
        'Замовлення вже готується, скасувати не можна',
        code: 'order.cannot_cancel',
      ),
    );
  }
}

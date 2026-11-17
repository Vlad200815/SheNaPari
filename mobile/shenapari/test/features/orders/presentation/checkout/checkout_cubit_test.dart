import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/menu/domain/entities/break_slot.dart';
import 'package:shenapari/features/menu/domain/entities/canteen.dart';
import 'package:shenapari/features/menu/domain/menu_repository.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/orders/domain/orders_repository.dart';
import 'package:shenapari/features/orders/presentation/checkout/checkout_cubit.dart';
import 'package:shenapari/features/orders/presentation/checkout/checkout_state.dart';

import '../../../menu/menu_samples.dart';

class _MockMenu extends Mock implements MenuRepository {}

class _MockOrders extends Mock implements OrdersRepository {}

final _first = BreakSlot(
  id: 1,
  startsAt: DateTime(2026, 11, 17, 11, 40),
  endsAt: DateTime(2026, 11, 17, 12, 0),
);
final _second = BreakSlot(
  id: 2,
  startsAt: DateTime(2026, 11, 17, 13, 20),
  endsAt: DateTime(2026, 11, 17, 13, 50),
);
const _items = [CartItem(dish: cheeseburger, quantity: 2)];
final _order = Order(
  id: 'o1',
  number: 7,
  status: OrderStatus.paid,
  totalKopecks: 17000,
  createdAt: DateTime(2026, 11, 17, 11, 0),
  items: const [],
  breakSlot: _first,
);

final _ready = CheckoutState(
  status: CheckoutStatus.ready,
  breaks: [_first, _second],
  breakSlotId: 1,
  provider: PaymentProvider.googlePay,
);

void main() {
  late _MockMenu menu;
  late _MockOrders orders;

  setUpAll(() => registerFallbackValue(PaymentProvider.googlePay));

  setUp(() {
    menu = _MockMenu();
    orders = _MockOrders();
    when(
      () => menu.getTodayBreaks(),
    ).thenAnswer((_) async => Ok([_first, _second]));
    when(
      () => menu.getCanteen(),
    ).thenAnswer((_) async => const Ok(sampleCanteen));
  });

  CheckoutCubit build() => CheckoutCubit(
    menu,
    orders,
    items: _items,
    defaultProvider: PaymentProvider.googlePay,
  );

  void answerOrder(Result<Order> result) => when(
    () => orders.placeOrder(
      items: any(named: 'items'),
      breakSlotId: any(named: 'breakSlotId'),
      provider: any(named: 'provider'),
    ),
  ).thenAnswer((_) async => result);

  blocTest<CheckoutCubit, CheckoutState>(
    'load picks the nearest break by default',
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const CheckoutState(provider: PaymentProvider.googlePay),
      _ready,
    ],
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'no breaks left today: «as soon as possible» is chosen',
    setUp: () =>
        when(() => menu.getTodayBreaks()).thenAnswer((_) async => const Ok([])),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state.breakSlotId, isNull),
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'a paused kitchen disables paying',
    setUp: () => when(() => menu.getCanteen()).thenAnswer(
      (_) async => const Ok(Canteen(name: 'Їдальня', isAcceptingOrders: false)),
    ),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state.canPay, isFalse),
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'pays with the chosen break and provider',
    setUp: () => answerOrder(Ok(_order)),
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit
      ..selectBreak(null)
      ..selectProvider(PaymentProvider.applePay)
      ..pay(),
    skip: 2,
    expect: () => [
      _ready.copyWith(
        breakSlotId: null,
        provider: PaymentProvider.applePay,
        status: CheckoutStatus.placing,
      ),
      _ready.copyWith(
        breakSlotId: null,
        provider: PaymentProvider.applePay,
        status: CheckoutStatus.placed,
        order: _order,
      ),
    ],
    verify: (_) => verify(
      () => orders.placeOrder(
        items: _items,
        breakSlotId: null,
        provider: PaymentProvider.applePay,
      ),
    ).called(1),
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'the kitchen paused meanwhile: back to ready, paying disabled',
    setUp: () => answerOrder(
      const Err(
        ConflictFailure(
          'Кухня зараз не приймає замовлення',
          code: 'order.canteen_paused',
        ),
      ),
    ),
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit.pay(),
    verify: (cubit) {
      expect(cubit.state.status, CheckoutStatus.ready);
      expect(cubit.state.failure?.code, 'order.canteen_paused');
      expect(cubit.state.canPay, isFalse);
    },
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'the chosen break started: breaks reload, the next one is chosen',
    setUp: () {
      answerOrder(
        const Err(
          ConflictFailure(
            'Ця перерва вже почалась, оберіть іншу',
            code: 'order.break_passed',
          ),
        ),
      );
      when(() => menu.getTodayBreaks()).thenAnswer((_) async => Ok([_second]));
    },
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit.pay(),
    verify: (cubit) {
      expect(cubit.state.breaks, [_second]);
      expect(cubit.state.breakSlotId, 2);
      expect(cubit.state.failure?.code, 'order.break_passed');
      expect(cubit.state.canPay, isTrue);
    },
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'a second tap while paying is ignored',
    build: build,
    seed: () => _ready.copyWith(status: CheckoutStatus.placing),
    act: (cubit) => cubit.pay(),
    expect: () => const <CheckoutState>[],
  );
}

import 'dart:async';

import 'package:shenapari/core/device/qr_display_mode.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/core/session/auth_tokens.dart';
import 'package:shenapari/features/auth/domain/auth_repository.dart';
import 'package:shenapari/features/auth/domain/entities/sign_in.dart';
import 'package:shenapari/features/menu/domain/entities/break_slot.dart';
import 'package:shenapari/features/menu/domain/entities/canteen.dart';
import 'package:shenapari/features/menu/domain/entities/category.dart';
import 'package:shenapari/features/menu/domain/entities/dish.dart';
import 'package:shenapari/features/menu/domain/menu_repository.dart';
import 'package:shenapari/features/orders/domain/entities/order.dart';
import 'package:shenapari/features/notifications/domain/entities/app_notification.dart';
import 'package:shenapari/features/notifications/domain/notifications_repository.dart';
import 'package:shenapari/features/orders/domain/order_events.dart';
import 'package:shenapari/features/orders/domain/orders_repository.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';
import 'package:shenapari/features/profile/domain/profile_repository.dart';

/// Accepts the code [validCode]; a number in [knownPhones] is a returning
/// customer, any other is new. Answers like the real backend.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.knownPhones = const {}});

  static const validCode = '123456';
  final Set<String> knownPhones;
  int logoutCalls = 0;

  @override
  Future<Result<void>> requestCode({required String phone}) async =>
      const Ok(null);

  @override
  Future<Result<SignIn>> verifyCode({
    required String phone,
    required String code,
  }) async {
    if (code != validCode) {
      return const Err(
        ValidationFailure(
          'Невірний або прострочений код',
          code: 'auth.invalid_code',
        ),
      );
    }
    return Ok(
      SignIn(
        tokens: const AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
        isNewUser: !knownPhones.contains(phone),
      ),
    );
  }

  @override
  Future<Result<void>> logout({required String refreshToken}) async {
    logoutCalls++;
    return const Ok(null);
  }
}

class FakeProfileRepository implements ProfileRepository {
  String? savedName;
  bool orderPush = true;

  @override
  Future<Result<User>> setOrderPush({required bool enabled}) async {
    orderPush = enabled;
    return getMe();
  }

  int deleteCalls = 0;

  /// When set, deleting fails with it (like an active order on the server).
  Failure? deleteFailure;

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalls++;
    final failure = deleteFailure;
    return failure == null ? const Ok(null) : Err(failure);
  }

  @override
  Future<Result<User>> getMe() async => Ok(
    User(
      id: '1',
      role: UserRole.customer,
      name: savedName,
      orderPushEnabled: orderPush,
    ),
  );

  @override
  Future<Result<User>> updateName(String name) async {
    savedName = name;
    return Ok(User(id: '1', role: UserRole.customer, name: name));
  }
}

/// One category with one dish, no photos (widget tests have no network).
class FakeMenuRepository implements MenuRepository {
  /// The language the server would answer in (Accept-Language).
  FakeMenuRepository({this.language});

  final String Function()? language;

  @override
  Future<Result<Canteen>> getCanteen() async =>
      const Ok(Canteen(name: 'Їдальня №1', isAcceptingOrders: true));

  @override
  Future<Result<List<Category>>> getCategories() async => Ok([
    Category(id: 1, name: language?.call() == 'en' ? 'Burgers' : 'Бургери'),
  ]);

  @override
  Future<Result<List<Dish>>> getDishes() async => const Ok([
    Dish(
      id: 10,
      categoryId: 1,
      name: 'Чізбургер',
      priceKopecks: 8500,
      weightG: 250,
      kcal: 540,
    ),
  ]);

  @override
  Future<Result<Dish>> getDish(int id) async {
    final dishes = (await getDishes() as Ok<List<Dish>>).value;
    for (final dish in dishes) {
      if (dish.id == id) return Ok(dish);
    }
    return const Err(
      NotFoundFailure('Страву не знайдено', code: 'menu.dish_not_found'),
    );
  }

  @override
  Future<Result<BreakSlot?>> getNextBreak() async => const Ok(null);

  @override
  Future<Result<List<BreakSlot>>> getTodayBreaks() async => const Ok([]);
}

/// Accepts orders as №7, №8…, priced from the cart, and keeps them so the
/// tracking screens can read it. [kitchen] moves it on like the cook would.
class FakeOrdersRepository implements OrdersRepository {
  final placed =
      <({List<CartItem> items, int? breakSlotId, PaymentProvider provider})>[];
  final orders = <Order>[];

  @override
  Future<Result<Order>> placeOrder({
    required List<CartItem> items,
    required int? breakSlotId,
    required PaymentProvider provider,
  }) async {
    placed.add((items: items, breakSlotId: breakSlotId, provider: provider));
    final now = DateTime(2026, 11, 17, 11);
    final number = 7 + orders.length;
    final order = Order(
      id: 'order-$number',
      number: number,
      status: OrderStatus.paid,
      totalKopecks: items.fold(0, (sum, item) => sum + item.totalKopecks),
      createdAt: now,
      items: [
        for (final item in items)
          OrderItem(
            dishId: item.dish.id,
            name: item.dish.name,
            quantity: item.quantity,
            unitPriceKopecks: item.dish.priceKopecks,
          ),
      ],
      history: [OrderStatusChange(status: OrderStatus.paid, at: now)],
    );
    orders.insert(0, order);
    return Ok(order);
  }

  /// What the kitchen does on the server.
  void kitchen(String id, OrderStatus status, {String? pickupToken}) {
    final i = orders.indexWhere((o) => o.id == id);
    final old = orders[i];
    orders[i] = Order(
      id: old.id,
      number: old.number,
      status: status,
      totalKopecks: old.totalKopecks,
      createdAt: old.createdAt,
      items: old.items,
      history: [
        ...old.history,
        OrderStatusChange(status: status, at: DateTime(2026, 11, 17, 11, 20)),
      ],
      pickupToken: pickupToken,
    );
  }

  @override
  Future<Result<List<Order>>> getMyOrders() async => Ok(List.of(orders));

  @override
  Future<Result<Order>> getOrder(String id) async {
    for (final order in orders) {
      if (order.id == id) return Ok(order);
    }
    return const Err(NotFoundFailure('Замовлення не знайдено'));
  }

  @override
  Future<Result<Order>> cancel(String id) async {
    kitchen(id, OrderStatus.cancelled);
    return getOrder(id);
  }
}

/// Live updates the test pushes by hand.
class FakeOrderEvents implements OrderEvents {
  final _controller = StreamController<String?>.broadcast();

  void changed(String? orderId) => _controller.add(orderId);

  @override
  Stream<String?> get changes => _controller.stream;
}

/// Notifications kept in memory; [add] is what the server does when the
/// kitchen changes a status.
class FakeNotificationsRepository implements NotificationsRepository {
  final items = <AppNotification>[];
  int markReadCalls = 0;

  void add(String title, {String? orderId}) => items.insert(
    0,
    AppNotification(
      id: 'n${items.length + 1}',
      orderId: orderId,
      title: title,
      body: 'Покажіть QR-код на видачі',
      createdAt: DateTime(2026, 11, 17, 11, 30),
      isRead: false,
    ),
  );

  @override
  Future<Result<List<AppNotification>>> getAll() async => Ok(List.of(items));

  @override
  Future<Result<void>> markAllRead() async {
    markReadCalls++;
    for (var i = 0; i < items.length; i++) {
      final n = items[i];
      items[i] = AppNotification(
        id: n.id,
        orderId: n.orderId,
        title: n.title,
        body: n.body,
        createdAt: n.createdAt,
        isRead: true,
      );
    }
    return const Ok(null);
  }
}

/// Records what the QR sheet asked the phone to do.
class FakeQrDisplayMode implements QrDisplayMode {
  var on = false;
  var enters = 0;

  @override
  Future<void> enter() async {
    on = true;
    enters++;
  }

  @override
  Future<void> exit() async => on = false;
}

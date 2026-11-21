import 'dart:async';

import 'package:kitchen/core/device/new_order_alert.dart';
import 'package:kitchen/features/auth/domain/staff_auth_repository.dart';
import 'package:kitchen/features/canteen/domain/canteen_repository.dart';
import 'package:kitchen/features/queue/domain/entities/kitchen_order.dart';
import 'package:kitchen/features/queue/domain/queue_repository.dart';
import 'package:kitchen/features/stop_list/domain/entities/stop_list_dish.dart';
import 'package:kitchen/features/stop_list/domain/stop_list_repository.dart';
import 'package:shenapari_core/orders/order_events.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/session/auth_tokens.dart';

/// Accepts [email] / [password]; anything else is the server's 401.
class FakeStaffAuthRepository implements StaffAuthRepository {
  FakeStaffAuthRepository({
    this.email = 'cook@shenapari.local',
    this.password = 'Cook12345!',
  });

  final String email;
  final String password;
  final logouts = <String>[];

  static const tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

  @override
  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  }) async => email == this.email && password == this.password
      ? const Ok(tokens)
      : const Err(
          UnauthorizedFailure(
            'Невірний email або пароль',
            code: 'auth.invalid_credentials',
          ),
        );

  @override
  Future<Result<void>> logout({required String refreshToken}) async {
    logouts.add(refreshToken);
    return const Ok(null);
  }
}

/// The board as the server would hold it; actions change [orders] the way
/// the server does.
class FakeQueueRepository implements QueueRepository {
  FakeQueueRepository([List<KitchenOrder>? orders]) : orders = orders ?? [];

  List<KitchenOrder> orders;
  final calls = <String>[];
  Failure? failNext;

  @override
  Future<Result<List<KitchenOrder>>> getQueue() async {
    calls.add('get');
    return Ok(List.of(orders));
  }

  /// QR tokens of ready orders: token → order id.
  final tokens = <String, String>{};

  @override
  Future<Result<KitchenOrder>> pickUp(String token) async {
    calls.add('pickUp $token');
    final id = tokens[token];
    final order = orders.where((o) => o.id == id).firstOrNull;
    if (order == null) {
      return const Err(
        NotFoundFailure('Замовлення не знайдено', code: 'order.not_found'),
      );
    }
    if (order.status != OrderStatus.ready) {
      return const Err(
        ConflictFailure('Замовлення ще не готове', code: 'order.not_ready'),
      );
    }
    _set(order.id, OrderStatus.pickedUp);
    return Ok(order);
  }

  @override
  Future<Result<void>> accept(String id, {required int minutes}) async {
    calls.add('accept $id $minutes');
    if (_fail() case final failure?) return Err(failure);
    _set(id, OrderStatus.cooking);
    return const Ok(null);
  }

  @override
  Future<Result<void>> setStatus(
    String id,
    OrderStatus status, {
    String? reason,
  }) async {
    calls.add(
      reason == null ? '${status.name} $id' : '${status.name} $id: $reason',
    );
    if (_fail() case final failure?) return Err(failure);
    _set(id, status);
    return const Ok(null);
  }

  Failure? _fail() {
    final failure = failNext;
    failNext = null;
    return failure;
  }

  void _set(String id, OrderStatus status) {
    orders = [
      for (final o in orders)
        if (o.id != id)
          o
        else if (status != OrderStatus.pickedUp &&
            status != OrderStatus.cancelled)
          KitchenOrder(
            id: o.id,
            number: o.number,
            status: status,
            createdAt: o.createdAt,
            items: o.items,
            customerName: o.customerName,
            breakStartsAt: o.breakStartsAt,
            estimatedReadyAt: o.estimatedReadyAt,
            readyAt: o.readyAt,
          ),
    ];
  }
}

class FakeOrderEvents implements OrderEvents {
  final _controller = StreamController<String?>.broadcast();

  void changed(String? id) => _controller.add(id);

  final _accepting = StreamController<bool>.broadcast();

  void acceptingChanged(bool accepting) => _accepting.add(accepting);

  @override
  Stream<bool> get acceptingOrders => _accepting.stream;

  @override
  Stream<String?> get changes => _controller.stream;
}

class FakeNewOrderAlert implements NewOrderAlert {
  int plays = 0;

  @override
  Future<void> play() async => plays++;
}

/// An order on the board: [minute] past 11:00 today it was paid.
KitchenOrder order(
  int number, {
  OrderStatus status = OrderStatus.paid,
  DateTime? breakAt,
  int minute = 0,
  DateTime? eta,
  DateTime? readyAt,
  String? name,
}) => KitchenOrder(
  id: 'o$number',
  number: number,
  status: status,
  createdAt: DateTime(2026, 11, 20, 11, minute),
  items: const [KitchenOrderItem(name: 'Борщ', quantity: 2)],
  breakStartsAt: breakAt,
  estimatedReadyAt: eta,
  readyAt: readyAt,
  customerName: name,
);

/// The canteen's pause switch as the server holds it.
class FakeCanteenRepository implements CanteenRepository {
  FakeCanteenRepository({this.accepting = true});

  bool accepting;
  final calls = <String>[];
  Failure? failNext;

  @override
  Future<Result<bool>> isAcceptingOrders() async {
    calls.add('get');
    if (_fail() case final failure?) return Err(failure);
    return Ok(accepting);
  }

  @override
  Future<Result<bool>> setAcceptingOrders(bool accepting) async {
    calls.add(accepting ? 'resume' : 'pause');
    if (_fail() case final failure?) return Err(failure);
    this.accepting = accepting;
    return Ok(accepting);
  }

  Failure? _fail() {
    final failure = failNext;
    failNext = null;
    return failure;
  }
}

/// The menu as the server holds it; [fail] makes every availability
/// change of that dish fail.
class FakeStopListRepository implements StopListRepository {
  FakeStopListRepository({
    List<StopListDish>? dishes,
    this.categories = const [],
  }) : dishes = dishes ?? [];

  List<StopListDish> dishes;
  List<DishCategory> categories;
  final calls = <String>[];
  final fail = <int>{};
  Failure? failLoad;

  static const failure = ServerFailure('Сервер не відповідає');

  @override
  Future<Result<List<StopListDish>>> getDishes() async {
    calls.add('dishes');
    if (failLoad case final failure?) return Err(failure);
    return Ok(List.of(dishes));
  }

  @override
  Future<Result<List<DishCategory>>> getCategories() async {
    calls.add('categories');
    return Ok(List.of(categories));
  }

  @override
  Future<Result<StopListDish>> setAvailable(int id, bool available) async {
    calls.add('${available ? 'on' : 'off'} $id');
    if (fail.contains(id)) return const Err(failure);
    final dish = dishes.firstWhere((d) => d.id == id).withAvailable(available);
    dishes = [for (final d in dishes) d.id == id ? dish : d];
    return Ok(dish);
  }
}

StopListDish dish(int id, String name, {int categoryId = 1, bool on = true}) =>
    StopListDish(id: id, categoryId: categoryId, name: name, isAvailable: on);

import 'dart:async';

import 'package:kitchen/core/device/new_order_alert.dart';
import 'package:kitchen/features/auth/domain/staff_auth_repository.dart';
import 'package:kitchen/features/queue/domain/entities/kitchen_order.dart';
import 'package:kitchen/features/queue/domain/queue_repository.dart';
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

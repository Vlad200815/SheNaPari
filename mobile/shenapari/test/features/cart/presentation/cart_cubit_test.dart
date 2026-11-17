import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/core/session/session_status.dart';
import 'package:shenapari/features/cart/domain/cart_repository.dart';
import 'package:shenapari/features/cart/domain/entities/cart.dart';
import 'package:shenapari/features/cart/presentation/cart_cubit.dart';

import '../../menu/menu_samples.dart';

class _MemoryCartRepository implements CartRepository {
  _MemoryCartRepository([this.stored = const Cart()]);

  Cart stored;

  @override
  Cart load() => stored;

  @override
  Future<void> save(Cart cart) async => stored = cart;
}

void main() {
  late StreamController<SessionStatus> session;

  setUp(() => session = StreamController<SessionStatus>.broadcast());
  tearDown(() => session.close());

  test('starts with the stored cart', () {
    final repository = _MemoryCartRepository(const Cart().add(lemonade));

    final cubit = CartCubit(repository, sessionChanges: session.stream);

    expect(cubit.state.quantityOf(lemonade.id), 1);
  });

  test('every change is saved', () {
    final repository = _MemoryCartRepository();
    final cubit = CartCubit(repository, sessionChanges: session.stream);

    cubit
      ..add(cheeseburger)
      ..setQuantity(cheeseburger, 3)
      ..add(lemonade)
      ..remove(lemonade.id);

    expect(repository.stored, const Cart().add(cheeseburger, quantity: 3));
  });

  test('signing out empties the cart', () async {
    final repository = _MemoryCartRepository(const Cart().add(lemonade));
    final cubit = CartCubit(repository, sessionChanges: session.stream);

    session.add(SessionStatus.unauthenticated);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, const Cart());
    expect(repository.stored, const Cart());
  });
}

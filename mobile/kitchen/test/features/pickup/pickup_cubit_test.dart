import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/pickup/presentation/pickup_cubit.dart';
import 'package:kitchen/features/pickup/presentation/pickup_state.dart';
import 'package:kitchen/features/queue/domain/entities/kitchen_order.dart';

import '../../fakes.dart';

void main() {
  const token = '3f2a9c10-5b7e-4d21-9a0c-1e2f3a4b5c6d';
  late FakeQueueRepository repository;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 11, 20, 12);
    repository = FakeQueueRepository([
      order(36, status: OrderStatus.ready, name: 'Влад'),
      order(38, status: OrderStatus.cooking),
    ])..tokens[token] = 'o36';
  });

  PickupCubit cubit() => PickupCubit(repository, clock: () => now);

  test('a scanned QR hands the order over at once', () async {
    final c = cubit();

    await c.scanned(token);

    expect(c.state.status, PickupStatus.done);
    expect(c.state.order?.number, 36);
    expect(c.state.handedOver, 1);
    expect(repository.calls, contains('pickUp $token'));
  });

  test('the same code seen again a moment later: one handover', () async {
    final c = cubit();
    await c.scanned(token);
    await c.scanned(token);

    expect(repository.calls.where((x) => x.startsWith('pickUp')), hasLength(1));

    now = now.add(PickupCubit.sameCodePause);
    await c.scanned(token);
    expect(c.state.status, PickupStatus.failed, reason: 'already handed over');
  });

  test('a QR that is not ours never reaches the server', () async {
    final c = cubit();

    await c.scanned('https://example.com/promo');

    expect(c.state.problem, PickupProblem.notOurCode);
    expect(repository.calls, isEmpty);
  });

  test('typed number: the order first, then «Видати»', () async {
    final c = cubit()
      ..digit(3)
      ..digit(6);

    await c.lookUp();
    expect(c.state.status, PickupStatus.found);
    expect(c.state.order?.customerName, 'Влад');

    await c.handOverFound();
    expect(c.state.status, PickupStatus.done);
    expect(c.state.number, '', reason: 'ready for the next one');
    expect(repository.calls, contains('pickedUp o36'));
  });

  test('a number not ready yet, or not on the board', () async {
    final c = cubit()
      ..digit(3)
      ..digit(8);
    await c.lookUp();
    expect(c.state.problem, PickupProblem.notReadyYet);

    c
      ..backspace()
      ..backspace()
      ..digit(9);
    await c.lookUp();
    expect(c.state.problem, PickupProblem.noSuchNumber);
  });

  test('the keypad takes up to three digits', () {
    final c = cubit()
      ..digit(1)
      ..digit(2)
      ..digit(3)
      ..digit(4);

    expect(c.state.number, '123');
  });
}

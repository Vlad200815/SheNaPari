import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen/features/canteen/presentation/canteen_cubit.dart';
import 'package:kitchen/features/canteen/presentation/canteen_state.dart';
import 'package:shenapari_core/result/failure.dart';

import '../../../fakes.dart';

void main() {
  late FakeCanteenRepository repository;
  late FakeOrderEvents events;

  setUp(() {
    repository = FakeCanteenRepository();
    events = FakeOrderEvents();
  });

  CanteenCubit cubit() => CanteenCubit(repository, events);

  test('loads whether the kitchen takes orders', () async {
    repository.accepting = false;
    final c = cubit();

    await c.load();

    expect(c.state.status, CanteenStatus.loaded);
    expect(c.state.accepting, isFalse);
  });

  test('a load error: the switch stays hidden', () async {
    repository.failNext = const ServerFailure('Сервер не відповідає');
    final c = cubit();

    await c.load();

    expect(c.state.status, CanteenStatus.failure);
  });

  test('pause, then resume', () async {
    final c = cubit();
    await c.load();

    await c.pause();
    expect(c.state.accepting, isFalse);
    expect(c.state.busy, isFalse);

    await c.resume();
    expect(c.state.accepting, isTrue);
    expect(repository.calls, ['get', 'pause', 'resume']);
  });

  test('pausing fails: still accepting, the reason is shown', () async {
    final c = cubit();
    await c.load();
    repository.failNext = const ForbiddenFailure('Немає доступу');

    await c.pause();

    expect(c.state.accepting, isTrue);
    expect(c.state.failure, isA<ForbiddenFailure>());
    expect(c.state.busy, isFalse);
  });

  test('pausing twice sends one request', () async {
    final c = cubit();
    await c.load();

    await Future.wait([c.pause(), c.pause()]);

    expect(repository.calls.where((x) => x == 'pause'), hasLength(1));
  });

  test('another device paused: follows it live', () async {
    final c = cubit();
    await c.load();

    events.acceptingChanged(false);
    await Future<void>.delayed(Duration.zero);

    expect(c.state.accepting, isFalse);
  });

  test('after a reconnect: asks the server again', () async {
    final c = cubit();
    await c.load();
    repository.accepting = false;

    events.changed(null);
    await Future<void>.delayed(Duration.zero);

    expect(c.state.accepting, isFalse);
    expect(repository.calls, ['get', 'get']);
  });
}

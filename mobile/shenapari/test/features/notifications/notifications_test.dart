import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/notifications/data/notifications_api.dart';
import 'package:shenapari/features/notifications/presentation/notifications_cubit.dart';
import 'package:shenapari/features/notifications/presentation/notifications_page.dart';

import '../../fakes.dart';

void main() {
  late FakeNotificationsRepository repository;
  late FakeOrderEvents events;

  setUp(() {
    repository = FakeNotificationsRepository();
    events = FakeOrderEvents();
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('reads GET /me/notifications', () {
    final item = NotificationDto.fromJson({
      'id': 'a1',
      'orderId': 'o7',
      'title': 'Замовлення №7 готове!',
      'body': 'Покажіть QR-код на видачі',
      'createdAt': '2026-11-17T09:30:00+00:00',
      'isRead': false,
    }).toEntity();

    expect(item.orderId, 'o7');
    expect(item.isRead, isFalse);
    expect(item.createdAt, DateTime.utc(2026, 11, 17, 9, 30).toLocal());
  });

  test(
    'opening the list marks everything read, new ones stay highlighted',
    () async {
      repository.add('Замовлення №7 прийнято');
      final cubit = NotificationsCubit(repository, events);

      await cubit.load();

      expect(repository.markReadCalls, 1);
      expect(cubit.state.items.single.isRead, isFalse, reason: 'as loaded');
      expect(repository.items.single.isRead, isTrue, reason: 'on the server');
      await cubit.close();
    },
  );

  test('nothing unread: no mark-read request', () async {
    final cubit = NotificationsCubit(repository, events);

    await cubit.load();

    expect(repository.markReadCalls, 0);
    await cubit.close();
  });

  test('the bell dot follows live order events', () async {
    final bell = UnreadNotificationsCubit(repository, events);
    await bell.load();
    expect(bell.state, isFalse);

    repository.add('Замовлення №7 готове!');
    events.changed('order-7');
    await flush();
    expect(bell.state, isTrue);

    bell.markSeen();
    expect(bell.state, isFalse);
    await bell.close();
  });

  test('time under a notification', () {
    final now = DateTime(2026, 11, 17, 20);
    expect(formatWhen(DateTime(2026, 11, 17, 11, 42), now), 'Сьогодні, 11:42');
    expect(formatWhen(DateTime(2026, 11, 16, 18, 5), now), 'Вчора, 18:05');
    expect(formatWhen(DateTime(2026, 11, 14, 9, 30), now), '14.11, 09:30');
  });
}

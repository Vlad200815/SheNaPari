import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/core/device/notification_permission.dart';
import 'package:shenapari/features/push/presentation/notification_nudge_cubit.dart';
import 'package:shenapari_core/storage/app_prefs.dart';

import '../../fakes.dart';

void main() {
  late AppPrefs prefs;
  late FakeNotificationPermission permission;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPrefs(await SharedPreferences.getInstance());
    permission = FakeNotificationPermission();
  });

  /// One «Оплачено» screen.
  Future<NotificationNudgeCubit> paid() async {
    final cubit = NotificationNudgeCubit(permission, prefs);
    await cubit.load();
    return cubit;
  }

  test('notifications on: no card', () async {
    permission.access = NotificationAccess.granted;

    expect((await paid()).state, isFalse);
  });

  test('off after the first order: the card shows', () async {
    expect((await paid()).state, isTrue);
    expect(prefs.paidOrders, 1);
  });

  test('«Увімкнути»: the system dialog, the card goes once allowed', () async {
    final cubit = await paid();

    await cubit.enable();

    expect(permission.requests, 1);
    expect(cubit.state, isFalse);
  });

  test('refused for good: «Увімкнути» opens the phone settings', () async {
    permission.access = NotificationAccess.blocked;
    final cubit = await paid();

    await cubit.enable();

    expect(permission.requests, 0);
    expect(permission.settingsOpened, 1);
  });

  test('«Не треба»: not on the next order, once more from the third', () async {
    await (await paid()).dismiss();

    expect((await paid()).state, isFalse, reason: 'second order');
    expect((await paid()).state, isTrue, reason: 'third order');
  });

  test('«Не треба» twice: never again', () async {
    await (await paid()).dismiss();
    await paid();
    await (await paid()).dismiss();

    for (var i = 0; i < 3; i++) {
      expect((await paid()).state, isFalse);
    }
  });
}

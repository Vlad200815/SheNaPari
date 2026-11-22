import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari_core/l10n/app_language.dart';
import 'package:shenapari_core/l10n/app_locale.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/storage/app_prefs.dart';
import 'package:shenapari/core/device/notification_permission.dart';
import 'package:shenapari/features/profile/domain/entities/user.dart';
import 'package:shenapari/features/profile/presentation/settings/settings_cubit.dart';

import '../../../../fakes.dart';

class _OfflineProfile extends FakeProfileRepository {
  @override
  Future<Result<User>> setOrderPush({required bool enabled}) async =>
      const Err(NetworkFailure());
}

void main() {
  late AppPrefs prefs;
  late AppLocale locale;
  late FakeNotificationPermission permission;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPrefs(await SharedPreferences.getInstance());
    // A phone set to German: the app has no German, so English.
    locale = AppLocale(prefs, deviceLanguageCode: () => 'de');
    permission = FakeNotificationPermission(NotificationAccess.granted);
  });

  test('theme: follows the phone until picked, then is kept', () async {
    final cubit = SettingsCubit(
      FakeProfileRepository(),
      prefs,
      locale,
      permission,
    );
    expect(cubit.state.themeMode, ThemeMode.system);

    await cubit.setThemeMode(ThemeMode.dark);

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(prefs.themeMode, ThemeMode.dark);
    expect(
      SettingsCubit(
        FakeProfileRepository(),
        prefs,
        locale,
        permission,
      ).state.themeMode,
      ThemeMode.dark,
      reason: 'kept between launches',
    );
  });

  test('language: follows the phone until picked, then is kept', () async {
    final cubit = SettingsCubit(
      FakeProfileRepository(),
      prefs,
      locale,
      permission,
    );
    expect(cubit.state.language, AppLanguage.system);
    expect(cubit.state.languageCode, 'en');

    await cubit.setLanguage(AppLanguage.uk);

    expect(cubit.state.language, AppLanguage.uk);
    expect(cubit.state.languageCode, 'uk');
    expect(prefs.language, AppLanguage.uk);
    expect(
      SettingsCubit(
        FakeProfileRepository(),
        prefs,
        locale,
        permission,
      ).state.language,
      AppLanguage.uk,
      reason: 'kept between launches',
    );

    await cubit.setLanguage(AppLanguage.system);
    expect(cubit.state.languageCode, 'en');
  });

  test(
    'the push switch is disabled until loaded, then shows the server value',
    () async {
      final repo = FakeProfileRepository()..orderPush = false;
      final cubit = SettingsCubit(repo, prefs, locale, permission);
      expect(cubit.state.orderPush, isNull);

      await cubit.load();

      expect(cubit.state.orderPush, isFalse);
    },
  );

  test('switching push off saves it on the server', () async {
    final repo = FakeProfileRepository();
    final cubit = SettingsCubit(repo, prefs, locale, permission);
    await cubit.load();

    await cubit.setOrderPush(false);

    expect(cubit.state.orderPush, isFalse);
    expect(repo.orderPush, isFalse);
  });

  test('a refused change switches back and says why', () async {
    final cubit = SettingsCubit(_OfflineProfile(), prefs, locale, permission);
    await cubit.load();

    await cubit.setOrderPush(false);

    expect(cubit.state.orderPush, isTrue);
    expect(cubit.state.failure, const NetworkFailure());
  });

  test('«Вимкнути анімації» is kept on the phone', () async {
    final cubit = SettingsCubit(
      FakeProfileRepository(),
      prefs,
      locale,
      permission,
    );

    await cubit.setReduceMotion(true);

    expect(prefs.reduceMotion, isTrue);
    expect(
      SettingsCubit(
        FakeProfileRepository(),
        prefs,
        locale,
        permission,
      ).state.reduceMotion,
      isTrue,
    );
  });

  test('sounds: on until switched off, then kept', () async {
    final cubit = SettingsCubit(
      FakeProfileRepository(),
      prefs,
      locale,
      permission,
    );
    expect(cubit.state.sounds, isTrue);

    await cubit.setSounds(false);

    expect(cubit.state.sounds, isFalse);
    expect(prefs.sounds, isFalse);
  });

  test(
    'notifications blocked by the phone: shown, the row opens settings',
    () async {
      permission.access = NotificationAccess.blocked;
      final cubit = SettingsCubit(
        FakeProfileRepository(),
        prefs,
        locale,
        permission,
      );

      await cubit.checkNotifications();
      expect(cubit.state.notifications, NotificationAccess.blocked);

      await cubit.fixNotifications();
      expect(permission.settingsOpened, 1);
    },
  );

  test('not asked yet: the row shows the system dialog', () async {
    permission.access = NotificationAccess.denied;
    final cubit = SettingsCubit(
      FakeProfileRepository(),
      prefs,
      locale,
      permission,
    );
    await cubit.checkNotifications();

    await cubit.fixNotifications();

    expect(permission.requests, 1);
    expect(cubit.state.notifications, NotificationAccess.granted);
  });
}

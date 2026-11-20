import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari_core/l10n/app_language.dart';
import 'package:shenapari_core/l10n/app_locale.dart';
import 'package:shenapari_core/result/failure.dart';
import 'package:shenapari_core/result/result.dart';
import 'package:shenapari_core/storage/app_prefs.dart';
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPrefs(await SharedPreferences.getInstance());
    // A phone set to German: the app has no German, so English.
    locale = AppLocale(prefs, deviceLanguageCode: () => 'de');
  });

  test('theme: follows the phone until picked, then is kept', () async {
    final cubit = SettingsCubit(FakeProfileRepository(), prefs, locale);
    expect(cubit.state.themeMode, ThemeMode.system);

    await cubit.setThemeMode(ThemeMode.dark);

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(prefs.themeMode, ThemeMode.dark);
    expect(
      SettingsCubit(FakeProfileRepository(), prefs, locale).state.themeMode,
      ThemeMode.dark,
      reason: 'kept between launches',
    );
  });

  test('language: follows the phone until picked, then is kept', () async {
    final cubit = SettingsCubit(FakeProfileRepository(), prefs, locale);
    expect(cubit.state.language, AppLanguage.system);
    expect(cubit.state.languageCode, 'en');

    await cubit.setLanguage(AppLanguage.uk);

    expect(cubit.state.language, AppLanguage.uk);
    expect(cubit.state.languageCode, 'uk');
    expect(prefs.language, AppLanguage.uk);
    expect(
      SettingsCubit(FakeProfileRepository(), prefs, locale).state.language,
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
      final cubit = SettingsCubit(repo, prefs, locale);
      expect(cubit.state.orderPush, isNull);

      await cubit.load();

      expect(cubit.state.orderPush, isFalse);
    },
  );

  test('switching push off saves it on the server', () async {
    final repo = FakeProfileRepository();
    final cubit = SettingsCubit(repo, prefs, locale);
    await cubit.load();

    await cubit.setOrderPush(false);

    expect(cubit.state.orderPush, isFalse);
    expect(repo.orderPush, isFalse);
  });

  test('a refused change switches back and says why', () async {
    final cubit = SettingsCubit(_OfflineProfile(), prefs, locale);
    await cubit.load();

    await cubit.setOrderPush(false);

    expect(cubit.state.orderPush, isTrue);
    expect(cubit.state.failure, const NetworkFailure());
  });

  test('«Вимкнути анімації» is kept on the phone', () async {
    final cubit = SettingsCubit(FakeProfileRepository(), prefs, locale);

    await cubit.setReduceMotion(true);

    expect(prefs.reduceMotion, isTrue);
    expect(
      SettingsCubit(FakeProfileRepository(), prefs, locale).state.reduceMotion,
      isTrue,
    );
  });
}

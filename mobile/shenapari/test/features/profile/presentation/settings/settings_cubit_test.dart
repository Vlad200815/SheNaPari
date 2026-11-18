import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/core/result/failure.dart';
import 'package:shenapari/core/result/result.dart';
import 'package:shenapari/core/storage/app_prefs.dart';
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPrefs(await SharedPreferences.getInstance());
  });

  test(
    'the push switch is disabled until loaded, then shows the server value',
    () async {
      final repo = FakeProfileRepository()..orderPush = false;
      final cubit = SettingsCubit(repo, prefs);
      expect(cubit.state.orderPush, isNull);

      await cubit.load();

      expect(cubit.state.orderPush, isFalse);
    },
  );

  test('switching push off saves it on the server', () async {
    final repo = FakeProfileRepository();
    final cubit = SettingsCubit(repo, prefs);
    await cubit.load();

    await cubit.setOrderPush(false);

    expect(cubit.state.orderPush, isFalse);
    expect(repo.orderPush, isFalse);
  });

  test('a refused change switches back and says why', () async {
    final cubit = SettingsCubit(_OfflineProfile(), prefs);
    await cubit.load();

    await cubit.setOrderPush(false);

    expect(cubit.state.orderPush, isTrue);
    expect(cubit.state.failure, const NetworkFailure());
  });

  test('«Вимкнути анімації» is kept on the phone', () async {
    final cubit = SettingsCubit(FakeProfileRepository(), prefs);

    await cubit.setReduceMotion(true);

    expect(prefs.reduceMotion, isTrue);
    expect(
      SettingsCubit(FakeProfileRepository(), prefs).state.reduceMotion,
      isTrue,
    );
  });
}

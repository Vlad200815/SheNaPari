import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari_core/core_module.dart';
import 'package:shenapari_core/storage/token_storage.dart';

import '../features/auth/auth_module.dart';
import 'env.dart';

/// Service locator. Use it only here, in feature modules and in
/// `BlocProvider(create: ...)`; classes get dependencies via constructors.
final sl = GetIt.instance;

void setupDi({required SharedPreferences prefs, TokenStorage? tokenStorage}) {
  registerCore(
    sl,
    apiBaseUrl: Env.apiBaseUrl,
    prefs: prefs,
    tokenStorage: tokenStorage,
  );
  registerAuth(sl);
}

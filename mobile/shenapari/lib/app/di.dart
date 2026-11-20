import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shenapari_core/core_module.dart';
import 'package:shenapari_core/storage/token_storage.dart';

import '../core/device/qr_display_mode.dart';
import '../features/auth/auth_module.dart';
import '../features/cart/cart_module.dart';
import '../features/legal/legal_module.dart';
import '../features/menu/menu_module.dart';
import '../features/notifications/notifications_module.dart';
import '../features/orders/orders_module.dart';
import '../features/profile/profile_module.dart';
import 'env.dart';

/// Service locator. Use it only here, in feature modules and in
/// `BlocProvider(create: ...)`; classes get dependencies via constructors.
final sl = GetIt.instance;

/// Collects the modules of all features.
void setupDi({required SharedPreferences prefs, TokenStorage? tokenStorage}) {
  registerCore(
    sl,
    apiBaseUrl: Env.apiBaseUrl,
    prefs: prefs,
    tokenStorage: tokenStorage,
  );
  // The customer's own device bits: brightness up and no screenshots at pickup.
  sl.registerLazySingleton<QrDisplayMode>(DeviceQrDisplayMode.new);
  registerAuth(sl);
  registerProfile(sl);
  registerMenu(sl);
  registerLegal(sl, prefs: prefs);
  registerCart(sl, prefs: prefs);
  registerOrders(sl);
  registerNotifications(sl);
}

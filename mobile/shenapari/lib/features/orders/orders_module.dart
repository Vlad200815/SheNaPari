import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:shenapari_core/session/session_repository.dart';
import '../cart/domain/entities/cart.dart';
import 'data/orders_api.dart';
import 'data/orders_repository_impl.dart';
import 'data/signalr_order_events.dart';
import 'domain/entities/order.dart';
import 'domain/order_events.dart';
import 'domain/orders_repository.dart';
import 'presentation/checkout/checkout_cubit.dart';
import 'presentation/order/order_cubit.dart';
import 'presentation/orders/order_history_cubit.dart';
import 'presentation/orders/orders_cubit.dart';

void registerOrders(GetIt sl) {
  sl
    ..registerLazySingleton<OrdersApi>(() => OrdersApi(sl()))
    ..registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(sl()))
    // One live connection shared by every screen that listens.
    ..registerLazySingleton<OrderEvents>(
      () => SignalROrderEvents(
        baseUrl: sl<Dio>().options.baseUrl,
        session: sl<SessionRepository>(),
      ),
    )
    ..registerFactoryParam<CheckoutCubit, List<CartItem>, PaymentProvider>(
      (items, provider) =>
          CheckoutCubit(sl(), sl(), items: items, defaultProvider: provider),
    )
    ..registerFactory(() => OrdersCubit(sl(), sl()))
    ..registerFactory(() => OrderHistoryCubit(sl(), sl()))
    ..registerFactoryParam<OrderCubit, String, void>(
      (id, _) => OrderCubit(sl(), sl(), orderId: id),
    );
}

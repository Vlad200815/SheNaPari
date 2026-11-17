import 'package:get_it/get_it.dart';

import '../cart/domain/entities/cart.dart';
import 'data/orders_api.dart';
import 'data/orders_repository_impl.dart';
import 'domain/entities/order.dart';
import 'domain/orders_repository.dart';
import 'presentation/checkout/checkout_cubit.dart';

void registerOrders(GetIt sl) {
  sl
    ..registerLazySingleton<OrdersApi>(() => OrdersApi(sl()))
    ..registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(sl()))
    ..registerFactoryParam<CheckoutCubit, List<CartItem>, PaymentProvider>(
      (items, provider) =>
          CheckoutCubit(sl(), sl(), items: items, defaultProvider: provider),
    );
}

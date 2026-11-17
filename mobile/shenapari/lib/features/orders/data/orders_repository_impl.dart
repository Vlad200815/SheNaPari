import '../../../core/network/api_call.dart';
import '../../../core/result/result.dart';
import '../../cart/domain/entities/cart.dart';
import '../domain/entities/order.dart';
import '../domain/orders_repository.dart';
import 'dto/order_dtos.dart';
import 'orders_api.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._api);

  final OrdersApi _api;

  @override
  Future<Result<Order>> placeOrder({
    required List<CartItem> items,
    required int? breakSlotId,
    required PaymentProvider provider,
  }) => apiCall(
    () => _api.create(
      CreateOrderDto(
        breakSlotId: breakSlotId,
        paymentProvider: OrderDto.providerName(provider),
        items: [
          for (final item in items)
            CreateOrderItemDto(dishId: item.dish.id, quantity: item.quantity),
        ],
      ),
    ),
    (dto) => dto.toEntity(),
  );
}

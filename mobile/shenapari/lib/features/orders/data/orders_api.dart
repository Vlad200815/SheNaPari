import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:shenapari_core/network/api_envelope.dart';
import 'dto/order_dtos.dart';

part 'orders_api.g.dart';

@RestApi()
abstract class OrdersApi {
  factory OrdersApi(Dio dio) = _OrdersApi;

  @POST('/orders')
  Future<ApiEnvelope<OrderDto>> create(@Body() CreateOrderDto body);

  @GET('/orders/my')
  Future<ApiEnvelope<List<OrderDto>>> getMy({@Query('active') bool? active});

  /// `status`: `PickedUp`, `Cancelled` or `NotPickedUp`; `before`: ISO time.
  @GET('/orders/my/history')
  Future<ApiEnvelope<OrderHistoryDto>> getHistory({
    @Query('status') String? status,
    @Query('before') String? before,
  });

  @GET('/orders/{id}')
  Future<ApiEnvelope<OrderDto>> getById(@Path('id') String id);

  @POST('/orders/{id}/cancel')
  Future<ApiEnvelope<OrderDto>> cancel(@Path('id') String id);
}

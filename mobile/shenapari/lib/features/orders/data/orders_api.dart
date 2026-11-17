import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/network/api_envelope.dart';
import 'dto/order_dtos.dart';

part 'orders_api.g.dart';

@RestApi()
abstract class OrdersApi {
  factory OrdersApi(Dio dio) = _OrdersApi;

  @POST('/orders')
  Future<ApiEnvelope<OrderDto>> create(@Body() CreateOrderDto body);
}

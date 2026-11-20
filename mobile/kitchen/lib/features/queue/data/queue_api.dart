import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shenapari_core/network/api_envelope.dart';

import 'dto/staff_order_dtos.dart';

part 'queue_api.g.dart';

@RestApi()
abstract class QueueApi {
  factory QueueApi(Dio dio) = _QueueApi;

  @GET('/staff/orders')
  Future<ApiEnvelope<List<StaffOrderDto>>> getQueue();

  @POST('/staff/orders/{id}/accept')
  Future<ApiEnvelope<StaffOrderDto>> accept(
    @Path('id') String id,
    @Body() AcceptOrderDto body,
  );

  @PATCH('/staff/orders/{id}/status')
  Future<ApiEnvelope<StaffOrderDto>> setStatus(
    @Path('id') String id,
    @Body() UpdateStatusDto body,
  );
}

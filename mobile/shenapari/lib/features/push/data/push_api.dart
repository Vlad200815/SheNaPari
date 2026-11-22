import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shenapari_core/network/api_envelope.dart';

part 'push_api.g.dart';

@RestApi()
abstract class PushApi {
  factory PushApi(Dio dio) = _PushApi;

  @PUT('/me/push-token')
  Future<ApiEnvelope<void>> setToken(@Body() PushTokenDto body);
}

@JsonSerializable(createFactory: false)
class PushTokenDto {
  const PushTokenDto({required this.token});

  final String token;

  Map<String, dynamic> toJson() => _$PushTokenDtoToJson(this);
}

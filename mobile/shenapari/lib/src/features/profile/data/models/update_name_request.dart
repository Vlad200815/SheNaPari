import 'package:json_annotation/json_annotation.dart';

part "update_name_request.g.dart";

@JsonSerializable()
class UpdateNameRequest {
  @JsonKey(name: "fullName")
  final String fullName;

  UpdateNameRequest({required this.fullName});

  /// Deserializer...
  factory UpdateNameRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateNameRequestFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$UpdateNameRequestToJson(this);
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part "refresh_jwt_request.g.dart";

@JsonSerializable()
class RefreshJwtRequest extends Equatable {
  /// refreshToken
  @JsonKey(name: "refreshToken")
  final String refreshToken;

  const RefreshJwtRequest({required this.refreshToken});

  /// Deserializer...
  factory RefreshJwtRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshJwtRequestFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$RefreshJwtRequestToJson(this);

  @override
  List<Object?> get props => [refreshToken];
}

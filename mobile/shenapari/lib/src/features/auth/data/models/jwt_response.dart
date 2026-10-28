import 'package:json_annotation/json_annotation.dart';
import 'package:shenapari/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:shenapari/src/features/profile/data/models/user.dart';

part "jwt_response.g.dart";

@JsonSerializable(explicitToJson: true)
class JWTResponse {
  /// accessToken
  @JsonKey(name: "accessToken")
  final String? accessToken;

  /// refreshToken
  @JsonKey(name: "refreshToken")
  final String? refreshToken;

  /// user
  @JsonKey(name: "user")
  final User? user;

  /// isNewUser
  @JsonKey(name: "isNewUser")
  final bool? isNewUser;

  const JWTResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isNewUser,
  });

  /// Deserializer...
  factory JWTResponse.fromJson(Map<String, dynamic> json) =>
      _$JWTResponseFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$JWTResponseToJson(this);

  /// To Entity
  JWTEntity toEntity() => JWTEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: user?.toEntity(),
    isNewUser: isNewUser,
  );
}

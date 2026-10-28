import 'package:json_annotation/json_annotation.dart';
import 'package:shenapari/src/features/profile/domain/entities/user_entity.dart';

part "user.g.dart";

@JsonSerializable()
class User {
  /// id
  @JsonKey(name: "id")
  final String? id;

  /// phone
  @JsonKey(name: "phone")
  final String? phone;

  /// fullName
  @JsonKey(name: "fullName")
  final String? fullName;

  /// role
  @JsonKey(name: "role")
  final String? role;

  /// loyaltyPoints
  @JsonKey(name: "loyaltyPoints")
  final int? loyaltyPoints;

  const User({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    required this.loyaltyPoints,
  });

  /// Deserializer...
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// To Entity...
  UserEntity toEntity() => UserEntity(
    id: id,
    fullName: fullName,
    phone: phone,
    loyaltyPoints: loyaltyPoints,
  );
}

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'me_dto.g.dart';

/// `data` of `GET /me` and `PATCH /me` (backend `MeDto`).
@JsonSerializable(createToJson: false)
class MeDto {
  const MeDto({
    required this.id,
    required this.role,
    this.name,
    this.phone,
    this.email,
  });

  factory MeDto.fromJson(Map<String, dynamic> json) => _$MeDtoFromJson(json);

  final String id;

  /// PascalCase from the server: `Customer`, `Cook`, `Admin`, `SuperAdmin`.
  final String role;
  final String? name;
  final String? phone;
  final String? email;

  User toEntity() => User(
    id: id,
    role: parseRole(role),
    name: name,
    phone: phone,
    email: email,
  );

  /// Unknown roles become [UserRole.unknown] instead of crashing the app.
  static UserRole parseRole(String value) =>
      UserRole.values.asNameMap()[value.isEmpty
          ? value
          : value[0].toLowerCase() + value.substring(1)] ??
      UserRole.unknown;
}

/// `PATCH /me`
@JsonSerializable(createFactory: false)
class UpdateMeDto {
  const UpdateMeDto({required this.name});

  final String name;

  Map<String, dynamic> toJson() => _$UpdateMeDtoToJson(this);
}

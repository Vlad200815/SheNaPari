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
    this.orderPushEnabled,
  });

  factory MeDto.fromJson(Map<String, dynamic> json) => _$MeDtoFromJson(json);

  final String id;

  /// PascalCase from the server: `Customer`, `Cook`, `Admin`, `SuperAdmin`.
  final String role;
  final String? name;
  final String? phone;
  final String? email;
  final bool? orderPushEnabled;

  User toEntity() => User(
    id: id,
    role: parseRole(role),
    name: name,
    phone: phone,
    email: email,
    orderPushEnabled: orderPushEnabled,
  );

  /// Unknown roles become [UserRole.unknown] instead of crashing the app.
  static UserRole parseRole(String value) =>
      UserRole.values.asNameMap()[value.isEmpty
          ? value
          : value[0].toLowerCase() + value.substring(1)] ??
      UserRole.unknown;
}

/// `PUT /me/settings`
@JsonSerializable(createFactory: false)
class MeSettingsDto {
  const MeSettingsDto({required this.orderPushEnabled});

  final bool orderPushEnabled;

  Map<String, dynamic> toJson() => _$MeSettingsDtoToJson(this);
}

/// `PATCH /me`
@JsonSerializable(createFactory: false)
class UpdateMeDto {
  const UpdateMeDto({required this.name});

  final String name;

  Map<String, dynamic> toJson() => _$UpdateMeDtoToJson(this);
}

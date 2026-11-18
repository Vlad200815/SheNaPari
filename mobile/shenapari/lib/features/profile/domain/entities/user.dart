import 'package:equatable/equatable.dart';

enum UserRole {
  customer,
  cook,
  admin,
  superAdmin,

  /// A role this app version does not know yet.
  unknown,
}

/// The signed-in user (`GET /me`).
class User extends Equatable {
  const User({
    required this.id,
    required this.role,
    this.name,
    this.phone,
    this.email,
    this.orderPushEnabled,
  });

  final String id;
  final UserRole role;
  final String? name;

  /// Set for customers.
  final String? phone;

  /// Set for staff.
  final String? email;

  /// Push about own orders; null for staff.
  final bool? orderPushEnabled;

  @override
  List<Object?> get props => [id, role, name, phone, email, orderPushEnabled];
}

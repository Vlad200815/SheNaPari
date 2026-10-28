import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id;
  final String? fullName;
  final String? phone;
  final int? loyaltyPoints;
  final String? role;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.loyaltyPoints,
    this.role,
  });

  @override
  List<Object?> get props => [id, fullName, phone, loyaltyPoints, role];
}

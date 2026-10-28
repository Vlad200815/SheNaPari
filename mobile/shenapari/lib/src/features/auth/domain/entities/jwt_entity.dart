import 'package:equatable/equatable.dart';
import 'package:shenapari/src/features/profile/domain/entities/user_entity.dart';

class JWTEntity extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final UserEntity? user;
  final bool? isNewUser;

  const JWTEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isNewUser,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user, isNewUser];
}

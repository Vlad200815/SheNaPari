import 'package:equatable/equatable.dart';

/// Access/refresh token pair (docs/api-contract.md §5).
class AuthTokens extends Equatable {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

import 'package:equatable/equatable.dart';

import 'package:shenapari_core/session/auth_tokens.dart';

/// The result of a successful code check.
class SignIn extends Equatable {
  const SignIn({required this.tokens, required this.isNewUser});

  final AuthTokens tokens;

  /// The customer has no name yet: the app asks for it before the menu.
  final bool isNewUser;

  @override
  List<Object?> get props => [tokens, isNewUser];
}

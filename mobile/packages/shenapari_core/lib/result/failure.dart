import 'package:equatable/equatable.dart';

/// Why an operation failed. Chosen by the HTTP status of the response
/// (see `failure_mapper.dart`), never by the text.
///
/// Being `sealed`, a `switch` over it must handle every case. Failures are
/// compared by value, which `bloc_test` relies on when comparing states.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.code});

  /// The server's text, in the app's language (`Accept-Language`). Empty
  /// for failures made on the client; show `failure.text` (core/l10n).
  final String message;

  /// Stable machine code from the server (`errors[0]`), for example
  /// `auth.invalid_code` or `order.canteen_paused`; all codes are listed in
  /// `backend/src/ShenaPari.Api/Common/Errors.cs`. Use it when a screen must
  /// react to one specific error. Null for failures made on the client.
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  bool get stringify => true;
}

/// No connection or timeout. Produced only by the client.
final class NetworkFailure extends Failure {
  const NetworkFailure() : super('');
}

/// 400.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// 401.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.code});
}

/// 403.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.code});
}

/// 404.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// 409.
final class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code});
}

/// 5xx, 429 and other server errors. For 429, [retryAfter] holds the pause
/// from the `Retry-After` header.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, this.retryAfter});

  final Duration? retryAfter;

  @override
  List<Object?> get props => [message, code, retryAfter];
}

/// A bug on the client side (e.g. a response that could not be parsed).
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

import 'package:dio/dio.dart';

import '../result/failure.dart';
import 'api_envelope.dart';

/// No text from the server: `failure.text` shows a generic one instead.
const genericErrorMessage = '';

/// Maps an HTTP status to a [Failure]. The decision is made by status,
/// never by text.
Failure failureForStatus(
  int? status,
  String message, {
  String? code,
  Duration? retryAfter,
}) => switch (status) {
  400 => ValidationFailure(message, code: code),
  401 => UnauthorizedFailure(message, code: code),
  403 => ForbiddenFailure(message, code: code),
  404 => NotFoundFailure(message, code: code),
  409 => ConflictFailure(message, code: code),
  _ => ServerFailure(message, code: code, retryAfter: retryAfter),
};

extension ApiEnvelopeToFailure on ApiEnvelope<dynamic> {
  /// [status] is the HTTP status of the response, when known.
  Failure toFailure({int? status, Duration? retryAfter}) => failureForStatus(
    status,
    message ?? genericErrorMessage,
    code: code,
    retryAfter: retryAfter,
  );
}

extension DioExceptionToFailure on DioException {
  Failure toFailure() {
    final response = this.response;
    if (response == null) {
      return type == DioExceptionType.cancel
          ? const UnexpectedFailure(genericErrorMessage)
          : const NetworkFailure();
    }

    final retryAfter = _retryAfter(response);
    final envelope = ApiEnvelope.tryParse(response.data);
    if (envelope != null) {
      return envelope.toFailure(
        status: response.statusCode,
        retryAfter: retryAfter,
      );
    }
    // Not an envelope (e.g. HTML from a proxy): only the HTTP status is known.
    return failureForStatus(
      response.statusCode,
      genericErrorMessage,
      retryAfter: retryAfter,
    );
  }

  static Duration? _retryAfter(Response<dynamic> response) {
    final seconds = int.tryParse(response.headers.value('retry-after') ?? '');
    return seconds == null ? null : Duration(seconds: seconds);
  }
}

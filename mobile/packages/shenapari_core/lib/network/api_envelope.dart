/// The wrapper every API response comes in, success or failure
/// (backend `Common/Result.cs`):
///
/// ```json
/// { "succeeded": true,  "message": null, "data": {...}, "errors": [] }
/// { "succeeded": false, "message": "Замовлення ще не готове", "data": null, "errors": ["order.not_ready"] }
/// ```
///
/// The HTTP status is real (400/401/404/409/429...), so failures are
/// classified by it. Never leaves the data layer: `apiCall` unwraps it.
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.succeeded,
    this.message,
    this.data,
    this.errors = const [],
  });

  /// [fromJsonT] converts `data`; it is not called when `data` is null.
  /// The signature matches what retrofit expects for generic responses.
  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final data = json['data'];
    final errors = json['errors'];
    return ApiEnvelope(
      succeeded: json['succeeded'] == true,
      message: json['message'] as String?,
      data: data == null ? null : fromJsonT(data),
      errors: errors is List
          ? errors.map((code) => code.toString()).toList()
          : const [],
    );
  }

  final bool succeeded;

  /// Ready-to-show text in Ukrainian; set when the request failed.
  final String? message;
  final T? data;

  /// Stable error codes such as `order.not_ready`.
  final List<String> errors;

  /// The first error code, or null.
  String? get code => errors.isEmpty ? null : errors.first;

  /// Reads an envelope from an arbitrary response body, ignoring `data`.
  /// Returns null when the body is not an envelope (e.g. HTML from a proxy).
  static ApiEnvelope<void>? tryParse(Object? body) {
    if (body is! Map<String, dynamic> || body['succeeded'] is! bool) {
      return null;
    }
    return ApiEnvelope<void>.fromJson(body, (_) {});
  }
}

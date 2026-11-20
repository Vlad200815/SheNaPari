import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../result/failure.dart';
import '../result/result.dart';
import 'api_envelope.dart';
import 'failure_mapper.dart';

/// Runs an API request that returns data and unwraps the envelope into a
/// [Result]. The single place where transport errors become [Failure]s, so
/// repositories need no try/catch.
///
/// A successful response without data is treated as a client/server
/// mismatch; use [apiCallVoid] for endpoints that return no data.
Future<Result<T>> apiCall<D, T>(
  Future<ApiEnvelope<D>> Function() request,
  T Function(D data) toEntity,
) => _guard(() async {
  final env = await request();
  if (!env.succeeded) return Err(_errorOf(env));
  final data = env.data;
  if (data == null) {
    developer.log('Successful response without data', name: 'apiCall');
    return const Err(UnexpectedFailure(genericErrorMessage));
  }
  return Ok(toEntity(data));
});

/// Same as [apiCall] for endpoints where "nothing" is a valid answer
/// (`GET /breaks/next` when no break is scheduled): `data: null` → `Ok(null)`.
Future<Result<T?>> apiCallNullable<D, T>(
  Future<ApiEnvelope<D>> Function() request,
  T Function(D data) toEntity,
) => _guard(() async {
  final env = await request();
  if (!env.succeeded) return Err(_errorOf(env));
  final data = env.data;
  return Ok(data == null ? null : toEntity(data));
});

/// Same as [apiCall] for endpoints that return no data (`data: null`).
Future<Result<void>> apiCallVoid(
  Future<ApiEnvelope<void>> Function() request,
) => _guard(() async {
  final env = await request();
  if (!env.succeeded) return Err(_errorOf(env));
  return const Ok(null);
});

/// A 2xx response with `succeeded: false`. The backend never sends one
/// (failures come with a real HTTP status), so the type is unknown.
Failure _errorOf(ApiEnvelope<dynamic> env) => env.toFailure();

Future<Result<T>> _guard<T>(Future<Result<T>> Function() body) async {
  try {
    return await body();
  } on DioException catch (e) {
    return Err(e.toFailure());
  } catch (e, stackTrace) {
    // A bug on our side (parsing, mapping). Log it, show a generic text.
    developer.log(
      'Unexpected error',
      name: 'apiCall',
      error: e,
      stackTrace: stackTrace,
    );
    return const Err(UnexpectedFailure(genericErrorMessage));
  }
}

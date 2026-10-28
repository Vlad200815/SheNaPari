import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shenapari/src/core/network/http_error.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';

import 'base_view_event.dart';

class ErrorViewHelper {
  static void handleError(Exception error, Function(ErrorViewEvent) callback) {
    switch (error.runtimeType) {
      case const (DioException):
        {
          switch ((error as DioException).type) {
            case DioExceptionType.connectionTimeout:
              _handleErrorInternetConnection(callback);
            case DioExceptionType.sendTimeout:
              _handleErrorInternetConnection(callback);
            case DioExceptionType.receiveTimeout:
              _handleErrorInternetConnection(callback);
            case DioExceptionType.badCertificate:
              _handleErrorInternetConnection(callback);
            case DioExceptionType.connectionError:
              _handleErrorInternetConnection(callback);
            case DioExceptionType.unknown:
              _handleErrorInternetConnection(callback);
            case DioExceptionType.badResponse:
              _handleHttpError(error, callback);
            default:
              {}
          }
        }
    }
  }

  static bool hasHttpCode(Exception error, int code) {
    if (error.runtimeType == DioException) {
      if ((error as DioException).type == DioExceptionType.badResponse) {
        return error.response?.statusCode == code;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static String httpErrorMessage(Exception error) {
    final defaultError = "Oops... An error occurred on the server.";
    if (error.runtimeType == DioException) {
      final exception = (error as DioException);
      if (exception.type == DioExceptionType.badResponse) {
        try {
          final Map<String, dynamic> parsed = json.decode(
            error.response.toString(),
          );
          final result = HttpError.fromJson(parsed);
          final message =
              result.message; //(result.errors?.firstOrNull)?.message;
          return message ?? "$defaultError(${error.response?.statusCode})";
        } catch (error) {
          return (exception.response?.toString()) ?? defaultError;
        }
      } else {
        return defaultError;
      }
    } else {
      return "Oops.. Error ${error.toString()}";
    }
  }

  static void _handleErrorInternetConnection(
    Function(ErrorViewEvent) callback,
  ) {
    callback(
      const ErrorViewEvent(
        null,
        ErrorType.no_internet,
        "Error internet connection.",
      ),
    );
  }

  static void _handleHttpError(
    DioException error,
    Function(ErrorViewEvent) callback,
  ) {
    if (error.response != null) {
      if (error.response?.statusCode == 401) {
        AppPreference.setAuthenticated(false);
      }
      final message = httpErrorMessage(error);
      callback(ErrorViewEvent(error, ErrorType.http, message));
    }
  }

  static bool isInternetConnectionError(Exception error) {
    if (error.runtimeType == DioException) {
      final dioExceptionType = (error as DioException).type;
      return dioExceptionType == DioExceptionType.connectionTimeout ||
          dioExceptionType == DioExceptionType.sendTimeout ||
          dioExceptionType == DioExceptionType.receiveTimeout ||
          dioExceptionType == DioExceptionType.badCertificate ||
          dioExceptionType == DioExceptionType.connectionError ||
          dioExceptionType == DioExceptionType.unknown;
    }
    return false;
  }
}

enum ErrorType { no_internet, http, other }

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'error_view_helper.dart';

/// Base class to represent one-shot event to be handled by page instance.
abstract class ViewAction extends Equatable {
  const ViewAction();

  @override
  List<Object?> get props => [];
}

@immutable
class InitialViewAction extends ViewAction {
  Uri uri;
  Map<String, String> pathParameters;
  Object? extra;

  InitialViewAction({
    required this.uri,
    required this.pathParameters,
    this.extra,
  });
}

@immutable
class ErrorViewAction extends ViewAction {
  const ErrorViewAction({
    required this.exception,
    required this.type,
    required this.message,
  });

  final Exception? exception;

  final String? message;

  final ErrorType type;

  @override
  List<Object?> get props => [exception, message, type];
}

class GlobalAction<T> extends ViewAction {
  const GlobalAction(this.data);

  final T? data;

  @override
  List<Object?> get props => [data];
}

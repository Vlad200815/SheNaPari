import 'package:equatable/equatable.dart';

import 'error_view_helper.dart';

/// Base class to represent one-shot event to be handled by page instance.
abstract class ViewEvent extends Equatable {
  const ViewEvent();

  @override
  List<Object?> get props => [];
}

class ErrorViewEvent extends ViewEvent {
  const ErrorViewEvent(this.exception, this.type, this.message);

  final Exception? exception;

  final String? message;

  final ErrorType type;

  @override
  List<Object?> get props => [exception, message, type];
}

class MessageViewEvent extends ViewEvent {
  const MessageViewEvent(this.text);

  final String? text;

  @override
  List<Object?> get props => [text];
}

class LoadingViewEvent extends ViewEvent {
  const LoadingViewEvent(this.show, {this.progress});

  final bool show;

  final int? progress;

  @override
  List<Object?> get props => [show, progress];
}

class AppEvent<T> extends ViewEvent {
  const AppEvent(this.data);

  final T? data;

  @override
  List<Object?> get props => [data];
}

class PagingResponseEvent<T> extends ViewEvent {
  final int dataId;
  final List<T>? list;
  final dynamic error;
  final int? nextPage;

  const PagingResponseEvent({
    required this.dataId,
    required this.list,
    required this.nextPage,
    this.error,
  });
}

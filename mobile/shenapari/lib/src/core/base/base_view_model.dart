import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_view_action.dart';
import 'base_view_event.dart';
import 'base_view_state.dart';
import 'error_view_helper.dart';
import 'live_data.dart';

class _Handler {
  const _Handler({required this.isType, required this.type});

  final bool Function(dynamic value) isType;
  final Type type;
}

abstract class BaseViewModel<
  VS extends ViewState,
  VE extends ViewEvent,
  VA extends ViewAction
>
    extends Bloc<ViewAction, VS> {
  final LiveData<ViewEvent?> events = LiveData.broadcast(null);
  final _handlers = <_Handler>[];

  bool isInitializedView = false;

  BaseViewModel(super.initialState) {
    on((action, emit) async {
      if (action is InitialViewAction) {
        isInitializedView = true;
        debugPrint(
          '$runtimeType:: onReceive ($action(uri = ${action.uri}, '
          'path params = ${action.pathParameters}, '
          'extra = ${action.extra}))',
        );
        await onViewCreate(
          emit,
          action.uri,
          action.pathParameters,
          action.extra,
        );
      }
      if (action is ErrorViewAction) {
        debugPrint('$runtimeType:: onReceive ($action()');
        await onErrors(emit, action.exception, action.type, action.message);
      } else if (action is GlobalAction) {
        await onAppAction(action, emit);
        debugPrint('$runtimeType:: onReceive ($action()');
      } else if (action is VA) {
        debugPrint('$runtimeType:: onReceive ($action()');
        await onViewAction(action, emit);
      }
    });
  }

  ///Called when view initialized and received params.
  Future<void> onViewCreate(
    Emitter<VS> emitter,
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) async {}

  ///Called when view page passes instance of [VA] to handle.
  Future<void> onViewAction(VA action, Emitter<VS> emitter) async {}

  ///Called when receive global app action.
  Future<void> onAppAction(GlobalAction action, Emitter<VS> emitter) async {}

  void register<E extends GlobalAction>(
    EventHandler<E, State> handler, {
    EventTransformer<E>? transformer,
  }) {
    // ignore: prefer_asserts_with_message
    assert(() {
      final handlerExists = _handlers.any((handler) => handler.type == E);
      if (handlerExists) {
        throw StateError(
          'on<$E> was called multiple times. '
          'There should only be a single event handler per event type.',
        );
      }
      _handlers.add(_Handler(isType: (dynamic e) => e is E, type: E));
      return true;
    }());
  }

  Future<void> onErrors(
    Emitter<VS> emitter,
    Exception? exception,
    ErrorType type,
    String? message,
  ) async {
    debugPrint(
      '$runtimeType:: onErrors ($exception) type = $type, message = $message',
    );
  }

  @protected
  void postEvent(VE event, Emitter<VS> emitter) {
    events.value = event;
    debugPrint('$runtimeType:: postEvent ($event)');
  }

  void loading(bool show) {
    events.value = LoadingViewEvent(show);
    debugPrint('$runtimeType:: postEvent (LoadingViewEvent($show))');
  }

  void message(String text) {
    events.value = MessageViewEvent(text);
    debugPrint('$runtimeType:: postEvent (MessageViewEvent($text))');
  }

  @protected
  void setThrowable(dynamic throwable) {
    if (throwable is Exception) {
      ErrorViewHelper.handleError(throwable, (event) {
        events.value = event;
      });
    } else if (throwable is TypeError) {
      final info = throwable.stackTrace?.toString().split("\n").firstOrNull;
      final path = info?.substring(info.indexOf("("), info.indexOf(")"));
      events.value = ErrorViewEvent(
        Exception(),
        ErrorType.other,
        "${throwable.toString()}\n\n$path.",
      );
    } else {
      events.value = ErrorViewEvent(
        Exception(),
        ErrorType.other,
        throwable.toString(),
      );
    }
  }
}

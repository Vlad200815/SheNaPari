import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';
import 'package:shenapari/src/core/servies/debounce.dart';

import '../../../generated/locale_keys.g.dart';
import 'back_button_interceptor.dart';
import 'base_application.dart';
import 'base_view_action.dart';
import 'base_view_event.dart';
import 'base_view_model.dart';
import 'base_view_state.dart';
import 'base_widget_lifecycle.dart';
import 'default_views.dart';
import 'error_view_helper.dart';

abstract class BasePage<
  VM extends BaseViewModel<VS, VE, VA>,
  VS extends ViewState,
  VE extends ViewEvent,
  VA extends ViewAction
>
    extends StatefulWidget
    implements BaseWidgetLifecycle {
  BasePage({super.key});

  GlobalKey rootKey = GlobalKey();

  bool get isWantKeepAlive => false;

  bool get isShowErrorMessage => true;
  ErrorViewEvent? _lastErrorEvent;
  LoadingViewEvent? _lastLoadingEvent;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  ///
  /// Called when a back gesture has been completed and committed,
  /// or back button pressed has been released and committed.
  ///
  bool onBackInvokedDispatcher(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint('$VM:: onBackPressed()');
    return false;
  }

  VM viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  );

  ///Receive events from view model
  void handleEvent(BuildContext context, VE event);

  ///Create page ui.
  Widget createView(BuildContext context, VS state);

  ///Create error view.
  Widget createErrorView(
    BuildContext context,
    VS state,
    Exception? exception,
    String? message,
    ErrorType? type,
  ) {
    return DefaultViews.error(message);
  }

  ///Create full screen loading view.
  Widget createLoadingView(BuildContext context, int? progress) {
    return DefaultViews.loading();
  }

  ///Send action from view to view model
  void postAction(BuildContext context, VA action, {bool isGlobal = false}) {
    Future.delayed(const Duration(milliseconds: 1), () {
      if (context.mounted) {
        context.read<VM>().add(isGlobal ? GlobalAction(action) : action);
        debugPrint('$VM:: postAction($action) isGlobal: $isGlobal');
        if (_lastErrorEvent != null) {
          context.read<VM>().events.value = null;
        }
      }
    });
  }

  @override
  Widget onCreateView(BuildContext context) {
    final state = GoRouterState.of(context);
    return BlocProvider(
      create: (context) =>
          viewModelProvider(state.uri, state.pathParameters, state.extra)..add(
            InitialViewAction(
              uri: state.uri,
              pathParameters: state.pathParameters,
              extra: state.extra,
            ),
          ),
      child: BlocBuilder<VM, VS>(
        builder: (context, state) {
          _onReceiveEvents(context);
          return Stack(
            key: rootKey,
            children:
                backgroundView(context, state) +
                [
                  createView(context, state),
                  _buildErrorWidget(context, state),
                  _buildLoadingWidget(context),
                ],
          );
        },
      ),
    );
  }

  @override
  void onInit(BuildContext context) {
    _addNavigationChangeListener(context);
    BackButtonInterceptor.add(onBackInvokedDispatcher);
    _subscriptions.add(
      appEventBus.on<GlobalAction>().listen((event) {
        if (context.mounted) context.read<VM>().add(event);
      }),
    );
    debugPrint('$VM:: onInit()');
  }

  @override
  void onResume(BuildContext context) {
    debugPrint('$VM:: onResume()');
  }

  @override
  void onStop(BuildContext context) {
    debugPrint('$VM:: onStop()');
  }

  @override
  void onDestroy() {
    _removeNavigationChangeListener();
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    BackButtonInterceptor.remove(onBackInvokedDispatcher);
    debugPrint('$VM:: onDestroy()');
  }

  @override
  State<BasePage> createState() => _BasePageState(this);

  List<Widget> backgroundView(BuildContext context, VS state) => [];

  ///
  /// Build dynamic widget by difference errors.
  ///
  Widget _buildErrorWidget(BuildContext context, VS state) {
    return StreamBuilder<ViewEvent?>(
      stream: context.read<VM>().events.stream,
      builder: (BuildContext context, AsyncSnapshot<ViewEvent?> result) {
        if (result.data != null && result.data is ErrorViewEvent) {
          _lastErrorEvent = result.data as ErrorViewEvent;
        } else {
          _lastErrorEvent = null;
        }
        return Visibility(
          visible: _lastErrorEvent != null,
          child: createErrorView(
            context,
            state,
            _lastErrorEvent?.exception,
            _lastErrorEvent?.message,
            _lastErrorEvent?.type,
          ),
        );
      },
    );
  }

  ///
  /// Build dynamic loading widget.
  ///
  Widget _buildLoadingWidget(BuildContext context) {
    VM viewModel = context.read<VM>();
    return StreamBuilder<ViewEvent?>(
      stream: viewModel.events.stream,
      builder: (BuildContext context, AsyncSnapshot<ViewEvent?> result) {
        if (result.data != null && result.data is LoadingViewEvent) {
          _lastLoadingEvent = result.data as LoadingViewEvent?;
        } else {
          _lastLoadingEvent = null;
        }
        return Visibility(
          visible: (_lastLoadingEvent?.show).orFalse(),
          child: createLoadingView(context, _lastLoadingEvent?.progress),
        );
      },
    );
  }

  ///
  /// Setup view model event receiver
  ///
  @protected
  void _onReceiveEvents(BuildContext context) {
    VM viewModel = context.read<VM>();
    if (!viewModel.isInitializedView) {
      onInit(context);
      viewModel.events.listen((event) {
        if (event != null) {
          if (event is ErrorViewEvent) {
            viewModel.add(
              ErrorViewAction(
                exception: event.exception,
                type: event.type,
                message: event.message,
              ),
            );
            if (isShowErrorMessage) {
              _showSnackMessage(context, event.message);
            }
          } else if (event is MessageViewEvent) {
            _showSnackMessage(context, event.text);
          } else if (event is VE) {
            handleEvent(context, event);
          }
        }
        debugPrint('$VM:: handleEvent($event)');
      });
    }
  }

  ///
  /// On subscribe to navigation changed
  ///
  void _addNavigationChangeListener(BuildContext context) {
    GoRouter.of(
      context,
    ).routeInformationProvider.addListener(_onChangeNavigationInfo);
  }

  ///
  /// On unsubscribe to navigation changed
  ///
  void _removeNavigationChangeListener() {
    final context = rootKey.currentContext;
    if (context != null) {
      GoRouter.of(
        context,
      ).routeInformationProvider.removeListener(_onChangeNavigationInfo);
    }
  }

  ///
  /// On change navigation page information
  ///
  void _onChangeNavigationInfo() {
    final context = rootKey.currentContext;
    if (context != null) {
      final pageState = GoRouterState.of(context);
      final info = GoRouter.of(context).routeInformationProvider.value;
      if (info.state != null && info.state is RouteInformationState<void>) {
        final state = (info.state as RouteInformationState<void>);
        final isResume = state.type == NavigatingType.restore;
        if (isResume && pageState.uri == info.uri) {
          onResume(context);
        }
      }
    }
  }

  ///
  /// Show snack message
  ///
  void _showSnackMessage(BuildContext context, String? text) {
    Debounce.run("error-message", Duration(seconds: 1), () async {
      Get.snackbar(
        LocaleKeys.app_errors_title.tr,
        (text).orEmpty(),
        titleText: SizedBox(),
        messageText: Text((text).orEmpty(), style: ThemeText.poppinsMedium()),
        duration: Duration(seconds: 5),
        barBlur: 12,
      );
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text((text).orEmpty(),
                style: ThemeText.getBody(size: 14, color: ColorName.white))),
      );*/
    });
  }

  // void showErrorDialogEvent({
  //   required BuildContext context,
  //   String? title,
  //   required String message
  // }) {
  //   showAdaptiveDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return ComponentManager.alertDialog(
  //           // image: Assets.images.icNoConnection,
  //             title: title,
  //             message: message,
  //             positiveButton: LocaleKeys.app_close.tr,
  //             positiveButtonCallback: () {
  //               context.pop();
  //             }
  //         );
  //       }
  //   );
  // }
}

class _BasePageState extends State<BasePage>
    with AutomaticKeepAliveClientMixin<BasePage> {
  _BasePageState(this._listener);

  final BaseWidgetLifecycle _listener;

  late final AppLifecycleListener _appLifecycleListener;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _listener.onCreateView(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((it) {
      final context = widget.rootKey.currentContext;
      _appLifecycleListener = AppLifecycleListener(
        onResume: () => {if (context != null) _listener.onResume(context)},
        onHide: () => {if (context != null) _listener.onStop(context)},
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((it) {
      final context = widget.rootKey.currentContext;
      if (context != null) {
        _listener.onResume(context);
      }
    });
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    _listener.onDestroy();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.isWantKeepAlive;
}

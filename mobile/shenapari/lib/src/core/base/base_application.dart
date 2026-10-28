import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_view_action.dart';
import 'base_view_event.dart';
import 'base_view_model.dart';
import 'base_view_state.dart';
import 'base_widget_lifecycle.dart';
import 'event_bus.dart';

final appEventBus = EventBus();

final authNotifier = ValueNotifier<bool>(false);
final introNotifier = ValueNotifier<bool>(false);

abstract class BaseApplication<
  VM extends BaseViewModel<VS, VE, VA>,
  VS extends ViewState,
  VE extends ViewEvent,
  VA extends ViewAction
>
    extends StatefulWidget
    implements BaseWidgetLifecycle {
  BaseApplication({super.key});

  GlobalKey rootKey = GlobalKey();

  ///Receive events from view model
  void handleEvent(BuildContext context, VE event);

  ///Create app ui.
  Widget createView(BuildContext context, VS state);

  VM viewModel();

  ///Send action from view to view model
  void postAction(BuildContext context, VA action) {
    context.read<VM>().add(action);
    debugPrint('$VM:: postAction($action)');
  }

  @override
  Widget onCreateView(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel()
        ..add(
          InitialViewAction(
            uri: Uri.base,
            pathParameters: const {},
            extra: null,
          ),
        ),
      child: BlocBuilder<VM, VS>(
        builder: (context, state) {
          _onReceiveEvents(context);
          return createView(context, state);
        },
      ),
    );
  }

  void restartApp(BuildContext context) {
    final BaseApplicationState? appState = context
        .findAncestorStateOfType<BaseApplicationState>();
    appState?.restartApp();
  }

  @override
  void onInit(BuildContext context) {
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
    appEventBus.destroy();
    debugPrint('$VM:: onDestroy()');
  }

  @override
  State<BaseApplication> createState() => BaseApplicationState(this);

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
          } else if (event is VE) {
            handleEvent(context, event);
          }
        }
        debugPrint('$VM:: handleEvent($event)');
      });
    }
  }
}

class BaseApplicationState extends State<BaseApplication> {
  BaseApplicationState(this._listener);

  final BaseWidgetLifecycle _listener;

  late final AppLifecycleListener _appLifecycleListener;

  Key appKey = UniqueKey();

  void restartApp() {
    setState(() {
      appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: appKey, child: _listener.onCreateView(context));
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
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    _listener.onDestroy();
    super.dispose();
  }
}

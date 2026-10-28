import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_view_action.dart';
import 'base_view_event.dart';
import 'base_view_model.dart';
import 'base_view_state.dart';

abstract class BaseView<
  VM extends BaseViewModel<VS, VE, VA>,
  VS extends ViewState,
  VE extends ViewEvent,
  VA extends ViewAction
>
    extends StatelessWidget {
  const BaseView({super.key});

  Widget createView(BuildContext context, VS state);

  ///Send action from view to view model
  void postAction(BuildContext context, VA action) {
    context.read<VM>().add(action);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<VM>(context),
      child: BlocBuilder<VM, VS>(
        builder: (context, state) {
          return createView(context, state);
        },
      ),
    );
  }
}

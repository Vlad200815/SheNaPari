import 'package:flutter/material.dart';

abstract class BaseWidgetLifecycle {

  void onInit(BuildContext context);

  Widget onCreateView(BuildContext context);

  void onResume(BuildContext context);

  void onDestroy();

  void onStop(BuildContext context);
}


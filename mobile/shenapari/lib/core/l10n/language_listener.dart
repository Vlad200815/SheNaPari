import 'package:easy_localization/easy_localization.dart'
    show BuildContextEasyLocalizationExtension;
import 'package:flutter/widgets.dart';

/// Calls [onChanged] after the user switches the app's language, for
/// screens that show texts from the server (category names): those came in
/// the old language and have to be fetched again.
class LanguageListener extends StatefulWidget {
  const LanguageListener({
    super.key,
    required this.onChanged,
    required this.child,
  });

  /// Gets a context below this widget, so it can read the screen's cubits.
  final ValueChanged<BuildContext> onChanged;
  final Widget child;

  @override
  State<LanguageListener> createState() => _LanguageListenerState();
}

class _LanguageListenerState extends State<LanguageListener> {
  Locale? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reading the locale subscribes to it: this runs again on a switch.
    final locale = context.locale;
    final previous = _locale;
    _locale = locale;
    if (previous != null && previous != locale) widget.onChanged(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

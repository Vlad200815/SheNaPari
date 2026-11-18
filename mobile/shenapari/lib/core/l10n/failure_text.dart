import 'package:easy_localization/easy_localization.dart' show tr;

import '../../gen/locale_keys.gen.dart';
import '../result/failure.dart';

extension FailureText on Failure {
  /// What to show for this failure. Server failures carry the server's own
  /// text, already in the app's language (`Accept-Language`); failures made
  /// on the client have none and get theirs here.
  String get text => switch (this) {
    NetworkFailure() => tr(LocaleKeys.errors_network),
    _ when message.isEmpty => tr(LocaleKeys.errors_generic),
    _ => message,
  };
}

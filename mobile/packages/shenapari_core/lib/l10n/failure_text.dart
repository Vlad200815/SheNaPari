import 'package:easy_localization/easy_localization.dart' show tr;

import 'core_keys.dart';
import '../result/failure.dart';

extension FailureText on Failure {
  /// What to show for this failure. Server failures carry the server's own
  /// text, already in the app's language (`Accept-Language`); failures made
  /// on the client have none and get theirs here.
  String get text => switch (this) {
    NetworkFailure() => tr(CoreKeys.errorsNetwork),
    _ when message.isEmpty => tr(CoreKeys.errorsGeneric),
    _ => message,
  };
}

import 'dart:async';

import 'l10n_helper.dart';

/// Runs before every test file: the texts are Ukrainian unless a test
/// switches the language.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  loadTestTranslations();
  await testMain();
}

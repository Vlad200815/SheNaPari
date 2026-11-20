/// One import for texts: the app's generated keys, the shared ones and only
/// the parts of easy_localization we use (it re-exports all of `intl`, whose
/// names clash with Flutter's).
library;

export 'package:shenapari_core/l10n/l10n.dart';

export '../../gen/locale_keys.gen.dart';

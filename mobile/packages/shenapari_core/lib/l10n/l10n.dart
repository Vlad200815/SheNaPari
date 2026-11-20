/// One import for texts in the shared code: the keys it uses and only the
/// parts of easy_localization we need (it re-exports all of `intl`, whose
/// names clash with Flutter's).
library;

export 'package:easy_localization/easy_localization.dart'
    show
        BuildContextEasyLocalizationExtension,
        EasyLocalization,
        StringTranslateExtension,
        plural,
        tr;

export 'core_keys.dart';
export 'failure_text.dart';

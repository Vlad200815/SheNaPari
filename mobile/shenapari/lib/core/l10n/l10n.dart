/// One import for texts: the generated keys and only the parts of
/// easy_localization we use (it re-exports all of `intl`, whose names clash
/// with Flutter's).
library;

export 'package:easy_localization/easy_localization.dart'
    show
        BuildContextEasyLocalizationExtension,
        EasyLocalization,
        StringTranslateExtension,
        plural,
        tr;

export '../../gen/locale_keys.gen.dart';
export 'failure_text.dart';

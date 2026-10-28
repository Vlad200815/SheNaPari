// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/widgets.dart';
// import 'package:shenapari/src/data/storage/local/preference/app_preference.dart';
//
// class LocalizationHelper {
//
//   static Future<String> text(String key, {Locale? locale}) async {
//     final lang = await AppPreference.language;
//     final value = locale ?? Locale(lang);
//     final Map<String, dynamic> map = Map.from(await loadTranslationData(value));
//     final translate = Translate(map);
//     return Future.value(translate.get(key));
//   }
//
//   static Future<Translate> translations(Locale locale) async {
//     final Map<String, dynamic> map =
//     Map.from(await loadTranslationData(locale));
//     return Translate(map);
//   }
//
//   static Future<Map<String, dynamic>> loadTranslationData(
//       Locale locale) async =>
//       _combineAssetLoaders(
//         path: Localization.DIRECTORY,
//         locale: locale,
//         assetLoader: CodegenLoader(),
//         useOnlyLangCode: true,
//         extraAssetLoaders: [],
//       );
//
//   static Future<Map<String, dynamic>> _combineAssetLoaders({
//     required String path,
//     required Locale locale,
//     required AssetLoader assetLoader,
//     required bool useOnlyLangCode,
//     List<AssetLoader>? extraAssetLoaders,
//   }) async {
//     final result = <String, dynamic>{};
//     final loaderFutures = <Future<Map<String, dynamic>?>>[];
//
//     // need scriptCode, it might be better to use ignoreCountryCode as the variable name of useOnlyLangCode
//     final Locale desiredLocale = useOnlyLangCode
//         ? Locale.fromSubtags(
//         languageCode: locale.languageCode, scriptCode: locale.scriptCode)
//         : locale;
//
//     List<AssetLoader> loaders = [
//       assetLoader,
//       if (extraAssetLoaders != null) ...extraAssetLoaders
//     ];
//
//     for (final loader in loaders) {
//       loaderFutures.add(loader.load(path, desiredLocale));
//     }
//
//     await Future.wait(loaderFutures).then((List<Map<String, dynamic>?> value) {
//       for (final Map<String, dynamic>? map in value) {
//         if (map != null) {
//           result.addAllRecursive(map);
//         }
//       }
//     });
//
//     return result;
//   }
// }

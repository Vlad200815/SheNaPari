/// The translation keys the shared code uses. Each app keeps these in its
/// own `assets/translations/*.json` (a test in each app checks it).
abstract final class CoreKeys {
  static const appName = 'app.name';
  static const commonMore = 'common.more';
  static const commonLess = 'common.less';
  static const commonPlaceholder = 'common.placeholder';
  static const errorsGeneric = 'errors.generic';
  static const errorsNetwork = 'errors.network';

  static const all = [
    appName,
    commonMore,
    commonLess,
    commonPlaceholder,
    errorsGeneric,
    errorsNetwork,
  ];
}

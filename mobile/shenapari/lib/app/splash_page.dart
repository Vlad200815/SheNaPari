import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';

import '../gen/assets.gen.dart';

/// The route for the moment when the session status is not known yet.
/// It repeats the native splash exactly — the app background of the phone's
/// light or dark mode and the logo in the centre — so the handover from the
/// native splash to Flutter is invisible on iOS and every Android version.
///
/// The phone's mode, not the app's «Тема»: the native splash can't read the
/// app's setting, and the two must match.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @visibleForTesting
  static const backgroundKey = Key('splash-background');

  /// The native splash draws this 4x picture at a quarter of its pixels: the
  /// logo is 150 pt wide, as on Android 12+ (logo.png in a 288 dp icon).
  static final _logo = ExactAssetImage(
    Assets.images.splash.logoSplash.path,
    scale: 4,
  );

  /// Decodes the logo while the native splash is still up. Otherwise the
  /// first Flutter frame shows the background alone and the logo blinks.
  static Future<void> precacheLogo() {
    final done = Completer<void>();
    final stream = _logo.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (_, _) {
        stream.removeListener(listener);
        done.complete();
      },
      onError: (_, _) {
        stream.removeListener(listener);
        done.complete();
      },
    );
    stream.addListener(listener);
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return ColoredBox(
      key: backgroundKey,
      color: dark ? AppColors.dark.background : AppColors.light.background,
      child: Center(child: Image(image: _logo)),
    );
  }
}

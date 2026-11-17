import 'package:material_ui/material_ui.dart';

import '../gen/assets.gen.dart';

/// The route for the moment when the session status is not known yet.
/// It repeats the native splash (same background, same logo in the center),
/// so the handover from the native splash to Flutter is invisible.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Assets.images.splash.lightBackground.image(fit: BoxFit.cover),
          // The native splash draws the 4x image at a quarter of its pixel size.
          Center(child: Assets.images.splash.logo.image(scale: 4)),
        ],
      ),
    );
  }
}

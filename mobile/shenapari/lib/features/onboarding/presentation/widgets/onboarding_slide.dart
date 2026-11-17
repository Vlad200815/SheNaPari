import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';

/// One intro slide: a picture on the brand background, a title and a text.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.text,
    this.highlightText = false,
  });

  final AssetGenImage image;
  final String title;
  final String text;

  /// Draws [text] as a big orange gradient heading (the app name).
  final bool highlightText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding,
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Assets.images.onboarding.background.svg(),
                image.image(fit: BoxFit.contain),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            // Same height on every slide, so the buttons below do not move.
            constraints: const BoxConstraints(minHeight: 190),
            child: Column(
              children: [
                Text(
                  title,
                  style: AppText.heading(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (highlightText)
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [ColorName.primary400, ColorName.orange],
                    ).createShader(bounds),
                    child: Text(
                      text,
                      style: AppText.heading(color: ColorName.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Text(
                    text,
                    style: AppText.regular(color: ColorName.secondary500),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

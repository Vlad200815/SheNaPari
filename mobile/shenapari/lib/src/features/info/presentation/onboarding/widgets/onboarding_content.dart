import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:shenapari/gen/assets.gen.dart";
import "package:shenapari/gen/colors.gen.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/core/resource/theme_text.dart";

import "../../../../../core/widgets/widgets.dart";

class OnboardingContent extends StatelessWidget {
  final String image, title, subTitle;
  final int selectedIndex, length;

  const OnboardingContent({
    super.key,
    required this.image,
    required this.subTitle,
    required this.title,
    required this.selectedIndex,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SvgPicture.asset(Assets.images.onboarding.background.path),
                ImageView(url: image, fit: BoxFit.contain),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            flex: 3,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: ThemeText.poppinsHeading1(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                selectedIndex == 0
                    ? ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [ColorName.primary400, ColorName.orange],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        child: Text(
                          subTitle,
                          style: ThemeText.poppinsHeading1(
                            color: ColorName.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Text(
                        subTitle,
                        style: ThemeText.poppinsRegular(
                          color: ColorName.secondary500,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

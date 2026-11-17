import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../gen/colors.gen.dart';

/// The common frame of the sign-in screens: step in the app bar, a picture,
/// a title and a subtitle, the [form], and [bottom] pinned to the bottom
/// (it scrolls up with the keyboard instead of being covered by it).
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.step,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.bottom,
  });

  final String step;
  final Widget image;
  final String title;
  final String subtitle;
  final Widget form;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(step, style: AppText.medium(color: ColorName.black)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        height: constraints.maxHeight * 0.3,
                        child: image,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        title,
                        style: AppText.heading(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        subtitle,
                        style: AppText.regular(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      form,
                      const Spacer(),
                      const SizedBox(height: 8),
                      bottom,
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

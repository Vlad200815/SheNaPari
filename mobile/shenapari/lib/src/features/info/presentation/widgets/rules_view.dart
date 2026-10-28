import "package:flutter/material.dart";
import "package:flutter_markdown_plus/flutter_markdown_plus.dart";
import "package:shenapari/gen/colors.gen.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/core/resource/theme_text.dart";

class RulesView extends StatelessWidget {
  final String title, subTitle, documentContent;
  final ScrollController scrollController;
  final void Function(String, String?, String)? onTapLink;

  const RulesView({
    super.key,
    required this.title,
    required this.subTitle,
    required this.documentContent,
    required this.scrollController,
    required this.onTapLink,
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
          Text(
            title,
            style: ThemeText.poppinsHeading1(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subTitle,
            style: ThemeText.poppinsRegular(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorName.secondary200,
                  width: Dimen.DEFAULT_BORDER_WIDTH,
                ),
              ),
              child: RawScrollbar(
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                thickness: 8.5,
                radius: const Radius.circular(12),
                thumbVisibility: true,
                interactive: true,
                trackVisibility: true,
                // --- Styling the Track ---
                trackColor:
                    ColorName.secondary100, // Light background for the path
                trackBorderColor:
                    ColorName.secondary100, // Optional border for the path
                thumbColor: ColorName.secondary400,
                minThumbLength: 248,
                trackRadius: const Radius.circular(12),
                child: Markdown(
                  controller: scrollController,
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    left: 12,
                    right:
                        28, // Increase this until text no longer touches the bar
                  ),

                  data: documentContent,
                  onTapLink: (text, href, title) async =>
                      onTapLink?.call(text, href, title),
                  styleSheet: MarkdownStyleSheet(
                    h2: ThemeText.poppinsRegular(
                      fontWeight: FontWeight.bold,
                      color: ColorName.black,
                    ),

                    // 1. Style for your paragraph body text
                    p: ThemeText.poppinsRegular(),
                    pPadding: EdgeInsets.only(bottom: 8),

                    // Style for strong/bold text (your headers)
                    strong: ThemeText.poppinsRegular(
                      fontWeight: FontWeight.bold,
                    ),

                    // 3. Style for emphasis/italicized text (like *selected items*)
                    em: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 46),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shenapari/gen/colors.gen.dart';

class PageProgressBarView extends StatelessWidget {
  final int selectedPage;
  final int length;

  const PageProgressBarView({
    super.key,
    required this.selectedPage,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 12,
          width: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selectedPage == index
                ? ColorName.primary400
                //TODO: change this color, take from theme
                : Color(0xFFB9C0C9),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

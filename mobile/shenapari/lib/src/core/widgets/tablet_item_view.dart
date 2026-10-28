import "package:flutter/material.dart";

import "../../../gen/colors.gen.dart";

class TabletItemView extends StatelessWidget {
  const TabletItemView({super.key, required this.text, required this.height});

  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 1.5, vertical: 1.5),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorName.secondary200,
        ),
        padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 4),
        child: Text(text, style: TextStyle(color: ColorName.secondary500)),
      ),
    );
  }
}

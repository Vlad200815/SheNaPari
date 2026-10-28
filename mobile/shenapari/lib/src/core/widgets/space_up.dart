import "package:flutter/material.dart";

class SpaceUp extends StatelessWidget {
  final double height;

  const SpaceUp({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

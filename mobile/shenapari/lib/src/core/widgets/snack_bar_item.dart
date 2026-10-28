import 'package:flutter/material.dart';
import 'package:shenapari/gen/colors.gen.dart';

void showSnackBarItem(BuildContext context, {required String text}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), backgroundColor: ColorName.primary200),
  );
}

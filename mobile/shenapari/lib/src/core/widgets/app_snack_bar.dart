import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:shenapari/src/core/resource/theme_text.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showAppSnackBar(String text) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null || text.isEmpty) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 5),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF303030).withValues(alpha: 0.8), // підстав свій колір
              child: Text(text, style: ThemeText.poppinsMedium(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
}
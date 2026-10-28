import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';

class DefaultViews {
  ///
  /// Default full screen loader view.
  ///
  static Widget loading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6)),
      child: const CupertinoActivityIndicator(color: Colors.white, radius: 16),
    );
  }

  ///
  /// Default full screen error view.
  ///
  static Widget error(String? message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              Text(message.orEmpty()),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

//TODO: Add these texts to localization
void showRequiredPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // They MUST choose an option
    builder: (context) => AlertDialog(
      title: Text("Allow notifications"),
      content: Text(
        "To use Shenapari, we need to send you order updates. Please enable notifications in your phone settings.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            openAppSettings(); // Built-in function from permission_handler
            Navigator.pop(context);
          },
          child: Text("Open Settings"),
        ),
      ],
    ),
  );
}

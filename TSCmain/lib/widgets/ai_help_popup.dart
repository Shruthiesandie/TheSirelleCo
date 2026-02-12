import 'package:flutter/material.dart';

class AIHelpPopup {
  static void show(BuildContext context, String message) {
    // Delay showing snackbar until build frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}
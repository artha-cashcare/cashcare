// lib/utils/snackbar_service.dart

import 'package:flutter/material.dart';

class SnackBarService {
  static void showCustomSnackBar({
    required BuildContext context,
    required String message,
    required Icon icon,
    required Color backgroundColor,
    required Color textColor,
    int durationSeconds = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            icon,
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: durationSeconds),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

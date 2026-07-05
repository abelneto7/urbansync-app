import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SnackbarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.success);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.error);
  }

  static void _showSnackbar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.textOnAccent, fontSize: 14)),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

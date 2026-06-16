import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../widgets/app_text.dart';

class SnackbarUtils {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.success);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.error);
  }

  static void _showSnackbar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText.corpo(message, color: AppColors.textOnAccent),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

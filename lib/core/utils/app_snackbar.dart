import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influencer_app/core/theme/app_palette.dart';

class AppSnackbar {
  AppSnackbar._();

  static void showSuccessSnackbar({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppPalette.color1fill,
      borderColor: AppPalette.color1stroke,
      textColor: AppPalette.color1text,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showErrorSnackbar({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppPalette.color2fill,
      borderColor: AppPalette.color2stroke,
      textColor: AppPalette.color2text,
      icon: Icons.error_rounded,
    );
  }

  static void showWarningSnackbar({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppPalette.complemetaryFill,
      borderColor: AppPalette.color4Stroke,
      textColor: AppPalette.complemetary,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void showInformationSnackbar({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppPalette.thirdColor,
      borderColor: AppPalette.border1,
      textColor: AppPalette.primary,
      icon: Icons.info_rounded,
    );
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
  }) {
    Get.closeAllSnackbars();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: 1,
      colorText: textColor,
      icon: Icon(icon, color: textColor, size: 22),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      titleText: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: AppPalette.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

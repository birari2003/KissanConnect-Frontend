import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UiUtils {
  static void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: Duration(seconds: 3),
    );
  }

  static void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.error_outline, color: Colors.white),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: Duration(seconds: 4),
    );
  }

  static void showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.info_outline, color: Colors.white),
      isDismissible: true,
      duration: Duration(seconds: 3),
    );
  }

  static void showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
      isDismissible: true,
      duration: Duration(seconds: 3),
    );
  }
}

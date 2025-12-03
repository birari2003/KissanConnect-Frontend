import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_shetkari/app/routes/app_pages.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:ui';

class SplashScreenController extends GetxController {
  // Duration for splash screen before navigating
  final int splashDuration = 3500;

  @override
  void onInit() {
    super.onInit();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(Duration(milliseconds: splashDuration), () {
      onComplete();
    });
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Load saved language
    String? savedLanguage = prefs.getString('language');
    if (savedLanguage != null) {
      savedLanguage = savedLanguage.toLowerCase();
      // Map backend language names to codes (in case old data exists)
      if (savedLanguage == 'marathi')
        savedLanguage = 'mr';
      else if (savedLanguage == 'hindi')
        savedLanguage = 'hi';
      else if (savedLanguage == 'english')
        savedLanguage = 'en';

      await changeLocale(Get.context!, savedLanguage);
      Get.updateLocale(Locale(savedLanguage));
    }

    if (token != null && token.isNotEmpty) {
      // User is logged in, check role
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final role = userData['role'];

        if (role == 'farmer') {
          Get.offAllNamed('/farmerscreendashboard');
        } else if (role == 'admin') {
          Get.offAllNamed('/adminpanel');
        } else if (role == 'super_admin') {
          Get.offAllNamed('/superadminpanel');
        } else {
          Get.offAllNamed('/farmerscreendashboard');
        }
      } else {
        // Fallback if user data missing but token exists
        Get.offAllNamed('/farmerscreendashboard');
      }
    } else {
      // Not logged in, go to language selection
      Get.toNamed(Routes.SELECTLANGUAGE);
    }
  }

  void onComplete() {
    // Auto-navigation removed, waiting for user interaction
  }
}

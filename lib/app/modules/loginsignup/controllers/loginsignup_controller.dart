import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/authServices.dart';
import '../../../utils/ui_utils.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:ui';

class LoginsignupController extends GetxController {
  // Observable to toggle between login and signup
  final RxBool isLogin = true.obs;

  final AuthService _authService = AuthService();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Text editing controllers for Login
  final loginPhoneController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Text editing controllers for Signup
  final signupNameController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupRoleController = TextEditingController();

  // Observable for password visibility
  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isSignupPasswordVisible = false.obs;

  // Observable for loading state
  final RxBool isLoading = false.obs;

  // Role selection
  final RxString selectedRole = 'Farmer'.obs;
  final List<String> roles = ['Farmer', 'Super Admin', 'Admin'];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    // Dispose controllers
    loginPhoneController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupPhoneController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupRoleController.dispose();
    super.onClose();
  }

  void toggleView() {
    isLogin.value = !isLogin.value;
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void toggleSignupPasswordVisibility() {
    isSignupPasswordVisible.value = !isSignupPasswordVisible.value;
  }

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        final response = await _authService.loginUser(
          phone: loginPhoneController.text,
          password: loginPasswordController.text,
        );

        // Save session
        final prefs = await SharedPreferences.getInstance();
        if (response['token'] != null) {
          await prefs.setString('token', response['token']);
        }
        if (response['data'] != null) {
          await prefs.setString('user_data', jsonEncode(response['data']));

          // Save and apply language preference
          if (response['data']['language_preference'] != null) {
            String lang = response['data']['language_preference']
                .toString()
                .toLowerCase();

            // Map backend language names to codes
            if (lang == 'marathi')
              lang = 'mr';
            else if (lang == 'hindi')
              lang = 'hi';
            else if (lang == 'english')
              lang = 'en';

            await prefs.setString('language', lang);

            // Update app locale
            try {
              await changeLocale(Get.context!, lang);
              Get.updateLocale(Locale(lang));
            } catch (e) {
              // Handle error silently or log to crash reporting
            }
          }
        }

        UiUtils.showSuccessSnackbar(
          'Success',
          response['message'] ?? 'Login successful',
        );

        // Navigate based on role
        final role = response['data']['role'];
        if (role == 'farmer') {
          Get.offAllNamed('/farmerscreendashboard');
        } else if (role == 'admin') {
          Get.offAllNamed('/adminpanel');
        } else if (role == 'super_admin') {
          Get.offAllNamed('/superadminpanel');
        } else {
          // Default fallback
          Get.offAllNamed('/farmerscreendashboard');
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> signup() async {
    if (signupFormKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        // Get language from arguments or default to English
        final language = Get.arguments != null
            ? Get.arguments['language']
            : 'en';

        await _authService.registerUser(
          name: signupNameController.text,
          phone: signupPhoneController.text,
          email: signupEmailController.text,
          password: signupPasswordController.text,
          role: selectedRole.value.toLowerCase(),
          preferredLanguage: language,
        );

        Get.snackbar(
          'Success',
          'Registration successful. Please login.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Switch to login view
        isLogin.value = true;
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}

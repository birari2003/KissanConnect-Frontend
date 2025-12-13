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

  // Terms and Conditions acceptance
  final RxBool acceptedTerms = false.obs;

  void showTermsAndConditions() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2E8B57),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translate('terms_title'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('terms_content_1'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D323A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      translate('terms_content_2'),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 20),
                    // Terms points
                    ..._buildTermsPoints(),
                  ],
                ),
              ),
            ),
            // Close button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E8B57),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    translate('close'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  List<Widget> _buildTermsPoints() {
    final points = [
      {'title': 'terms_point_1', 'desc': 'terms_point_1_desc'},
      {'title': 'terms_point_2', 'desc': 'terms_point_2_desc'},
      {'title': 'terms_point_3', 'desc': 'terms_point_3_desc'},
      {'title': 'terms_point_4', 'desc': 'terms_point_4_desc'},
      {'title': 'terms_point_5', 'desc': 'terms_point_5_desc'},
      {'title': 'terms_point_6', 'desc': 'terms_point_6_desc'},
      {'title': 'terms_point_7', 'desc': 'terms_point_7_desc'},
      {'title': 'terms_point_8', 'desc': 'terms_point_8_desc'},
      {'title': 'terms_point_9', 'desc': 'terms_point_9_desc'},
      {'title': 'terms_point_10', 'desc': 'terms_point_10_desc'},
    ];

    return points.map((point) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate(point['title']!),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            SizedBox(height: 6),
            Text(
              translate(point['desc']!),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

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
      // Check if terms are accepted
      if (!acceptedTerms.value) {
        UiUtils.showErrorSnackbar(
          translate('error'),
          translate('must_accept_terms'),
        );
        return;
      }

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

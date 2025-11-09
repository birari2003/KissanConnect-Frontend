import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginsignupController extends GetxController {
  // Observable to toggle between login and signup
  final RxBool isLogin = true.obs;
  
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
  final List<String> roles = ['Farmer', 'Buyer', 'Supplier', 'Advisor'];

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
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual login logic
      print('Login - Phone: ${loginPhoneController.text}');
      
      isLoading.value = false;
      
      // Navigate to home on success
      Get.offAllNamed('/home');
    }
  }
  
  Future<void> signup() async {
    if (signupFormKey.currentState!.validate()) {
      isLoading.value = true;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual signup logic
      print('Signup - Name: ${signupNameController.text}');
      print('Phone: ${signupPhoneController.text}');
      print('Email: ${signupEmailController.text}');
      print('Role: ${selectedRole.value}');
      
      isLoading.value = false;
      
      // Navigate to home on success
      Get.offAllNamed('/home');
    }
  }
}

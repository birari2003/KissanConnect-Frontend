import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/loginsignup_controller.dart';

class LoginsignupView extends GetView<LoginsignupController> {
  const LoginsignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5CC96F).withOpacity(0.1),
              const Color(0xFF3C9ED0).withOpacity(0.1),
              const Color(0xFFFFC300).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // Login/Signup Form Card
                  _buildFormCard(),

                  const SizedBox(height: 20),

                  // Toggle between Login and Signup
                  _buildToggleButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E8B57).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/smartshetkari.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // App Name
        const Text(
          'Smart Shetkari',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D323A),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        Obx(
          () => Text(
            controller.isLogin.value ? 'Welcome Back!' : 'Create Your Account',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF2E8B57).withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: controller.isLogin.value
              ? _buildLoginForm()
              : _buildSignupForm(),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      key: const ValueKey('login'),
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: controller.loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D323A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF2D323A).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

            // Phone Field
            _buildTextField(
              controller: controller.loginPhoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Field
            Obx(
              () => _buildTextField(
                controller: controller.loginPasswordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: !controller.isLoginPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isLoginPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF2E8B57),
                  ),
                  onPressed: controller.toggleLoginPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),

            // Forgot Password
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(
            //     onPressed: () {
            //       // TODO: Implement forgot password
            //     },
            //     child: const Text(
            //       'Forgot Password?',
            //       style: TextStyle(
            //         color: Color(0xFF3C9ED0),
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ),

            // extra
            const SizedBox(height: 24),

            // Login Button
            Obx(
              () => _buildActionButton(
                text: 'Login',
                isLoading: controller.isLoading.value,
                onPressed: controller.login,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Padding(
      key: const ValueKey('signup'),
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: controller.signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D323A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your account to get started',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF2D323A).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            _buildTextField(
              controller: controller.signupNameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Phone Field
            _buildTextField(
              controller: controller.signupPhoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email Field
            _buildTextField(
              controller: controller.signupEmailController,
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Field
            Obx(
              () => _buildTextField(
                controller: controller.signupPasswordController,
                label: 'Password',
                hint: 'Create a password',
                icon: Icons.lock_outline,
                obscureText: !controller.isSignupPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isSignupPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF2E8B57),
                  ),
                  onPressed: controller.toggleSignupPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            // Role Selection
            _buildRoleSelector(),
            const SizedBox(height: 32),

            // Signup Button
            Obx(
              () => _buildActionButton(
                text: 'Sign Up',
                isLoading: controller.isLoading.value,
                onPressed: controller.signup,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Color(0xFF2D323A)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)),
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          color: Color(0xFF2E8B57),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: const Color(0xFF2D323A).withOpacity(0.4)),
        filled: true,
        fillColor: const Color(0xFF5CC96F).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF5CC96F).withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E8B57), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D323A),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.roles.map((role) {
              final isSelected = controller.selectedRole.value == role;
              return InkWell(
                onTap: () => controller.setRole(role),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E8B57)
                        : const Color(0xFF5CC96F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E8B57)
                          : const Color(0xFF5CC96F).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF2E8B57),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF5CC96F)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.isLogin.value
                ? "Don't have an account? "
                : "Already have an account? ",
            style: TextStyle(
              color: const Color(0xFF2D323A).withOpacity(0.7),
              fontSize: 15,
            ),
          ),
          TextButton(
            onPressed: controller.toggleView,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              controller.isLogin.value ? 'Sign Up' : 'Login',
              style: const TextStyle(
                color: Color(0xFF2E8B57),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

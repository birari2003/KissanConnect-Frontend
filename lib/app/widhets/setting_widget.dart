import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:convert';

import '../services/farmerServices.dart';
import '../services/translation_service.dart';

import '../utils/ui_utils.dart';
import '../controllers/payment_controller.dart';

class SettingsWidget extends StatefulWidget {
  final String selectedLanguage;
  final Function(String)? onLanguageChanged;

  const SettingsWidget({
    super.key,
    this.selectedLanguage = 'en-US',
    this.onLanguageChanged,
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'en-US';

  // Farmer Profile Data
  String _farmerName = 'Farmer';
  String _farmerEmail = '';
  String _farmerPhoto = '';
  final FarmerService _farmerService = FarmerService();
  final TranslationService _translationService = TranslationService();

  Future<String> _translateIfNeed(String text) async {
    try {
      String languageCode = 'en';
      if (Get.context != null) {
        try {
          languageCode = LocalizedApp.of(
            Get.context!,
          ).delegate.currentLocale.languageCode;
        } catch (e) {
          // Fallback or ignore
        }
      }
      return await _translationService.translateText(text, languageCode);
    } catch (e) {
      print('Error translating: $e');
      return text;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
    _loadSettings();
    _fetchFarmerProfile();
  }

  Future<void> _fetchFarmerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      // 1. Load basic user data from local storage first
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        if (mounted) {
          setState(() {
            if (userData['name'] != null) {
              _translateIfNeed(userData['name']).then((translatedName) {
                if (mounted) setState(() => _farmerName = translatedName);
              });
              _farmerName = userData['name']; // Show original first
            }

            if (userData['email'] != null) _farmerEmail = userData['email'];
          });
        }
      }

      // 2. Fetch full profile from API
      final profileData = await _farmerService.getFarmerProfile();
      if (profileData['success'] == true && profileData['data'] != null) {
        final data = profileData['data'];
        final user = data['user'];
        final profile = data['farmer_profile'];

        if (mounted) {
          setState(() {
            if (user != null) {
              if (user['name'] != null) {
                _translateIfNeed(user['name']).then((translatedName) {
                  if (mounted) setState(() => _farmerName = translatedName);
                });
                _farmerName = user['name'];
              }

              if (user['email'] != null) _farmerEmail = user['email'];
            }
            if (profile != null && profile['passport_photo'] != null) {
              _farmerPhoto = profile['passport_photo'];
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching profile in settings: $e');
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _selectedLanguage =
          prefs.getString('language') ?? widget.selectedLanguage;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _saveDarkModeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', value);
    setState(() {
      _darkModeEnabled = value;
    });
  }

  Future<void> _saveLanguageSetting(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    setState(() {
      _selectedLanguage = value;
    });
    widget.onLanguageChanged?.call(value);
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('logout_title')),
        content: Text(translate('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(translate('logout_title')),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Clear all user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          // Navigate to login screen
          Get.offAllNamed('/loginsignup');

          UiUtils.showSuccessSnackbar(
            translate('success_title'),
            translate('logout_success'),
          );
        }
      } catch (e) {
        print('Error during logout: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5CC96F).withOpacity(0.05),
              const Color(0xFF3C9ED0).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 24),
                      _buildSettingsSection(),
                      const SizedBox(height: 24),
                      _buildAboutSection(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2E8B57),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          translate('settings_title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF2E8B57), const Color(0xFF5CC96F)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2E8B57), const Color(0xFF5CC96F)],
              ),
              shape: BoxShape.circle,
              image: _farmerPhoto.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                        'http://192.168.43.43:5000/uploads/$_farmerPhoto',
                      ),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    )
                  : null,
            ),
            child: _farmerPhoto.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _farmerName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D323A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _farmerEmail.isNotEmpty
                      ? _farmerEmail
                      : translate('manage_account_settings'),
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2D323A).withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2E8B57)),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('preferences_section'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D323A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: translate('notifications_title'),
                subtitle: translate('notifications_subtitle'),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _saveNotificationSetting,
                  activeColor: const Color(0xFF2E8B57),
                ),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: translate('dark_mode_title'),
                subtitle: translate('dark_mode_subtitle'),
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: _saveDarkModeSetting,
                  activeColor: const Color(0xFF2E8B57),
                ),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.language_outlined,
                title: translate('language_title'),
                subtitle: _getLanguageName(_selectedLanguage),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('about_section'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D323A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.help_outline,
                title: translate('help_support_title'),
                subtitle: translate('help_support_subtitle'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to help
                },
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: translate('privacy_policy_title'),
                subtitle: translate('privacy_policy_subtitle'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: translate('about_app_title'),
                subtitle: translate(
                  'version_info',
                ), // Keeping version hardcoded or translatable if needed, usually version is standard
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Show about dialog
                  _showAboutDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.payment,
                title: translate('make_payment_title'),
                subtitle: translate('make_payment_subtitle'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final paymentController = Get.put(PaymentController());
                  await paymentController.startPayment();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E8B57).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2E8B57)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D323A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFF2D323A).withOpacity(0.6),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 24),
            SizedBox(width: 12),
            Text(
              translate('logout_title'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en-US':
        return 'English';
      case 'hi-IN':
        return 'हिंदी (Hindi)';
      case 'mr-IN':
        return 'मराठी (Marathi)';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en-US', 'English'),
            _buildLanguageOption('hi-IN', 'हिंदी (Hindi)'),
            _buildLanguageOption('mr-IN', 'मराठी (Marathi)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('cancel')),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name) {
    return RadioListTile<String>(
      title: Text(name),
      value: code,
      groupValue: _selectedLanguage,
      activeColor: const Color(0xFF2E8B57),
      onChanged: (value) {
        if (value != null) {
          _saveLanguageSetting(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('about_app_dialog_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('app_name'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            Text(translate('app_description')),
            const SizedBox(height: 16),
            Text(translate('copyright_text'), style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('close')),
          ),
        ],
      ),
    );
  }
}

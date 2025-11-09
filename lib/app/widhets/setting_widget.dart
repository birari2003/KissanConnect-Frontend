import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _selectedLanguage = prefs.getString('language') ?? widget.selectedLanguage;
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('token');
      await prefs.remove('isLoggedIn');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        // Replace with your actual login route
        Get.offAllNamed('/auth');
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
        title: const Text(
          'Settings',
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
              colors: [
                const Color(0xFF2E8B57),
                const Color(0xFF5CC96F),
              ],
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
                colors: [
                  const Color(0xFF2E8B57),
                  const Color(0xFF5CC96F),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Farmer Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D323A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your account settings',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2D323A).withOpacity(0.6),
                  ),
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
        const Text(
          'Preferences',
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
                title: 'Notifications',
                subtitle: 'Enable push notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _saveNotificationSetting,
                  activeColor: const Color(0xFF2E8B57),
                ),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Enable dark theme',
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: _saveDarkModeSetting,
                  activeColor: const Color(0xFF2E8B57),
                ),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.language_outlined,
                title: 'Language',
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
        const Text(
          'About',
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
                title: 'Help & Support',
                subtitle: 'Get help with the app',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to help
                },
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              const Divider(height: 1),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Show about dialog
                  _showAboutDialog();
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
          children: const [
            Icon(Icons.logout, size: 24),
            SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
        title: const Text('Select Language'),
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
            child: const Text('Cancel'),
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
        title: const Text('About KisaanConnect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KisaanConnect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'A comprehensive platform for farmers to manage their agricultural activities, connect with resources, and access government schemes.',
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2024 KisaanConnect. All rights reserved.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/superadminpanel_controller.dart';
import '../../../widhets/admin_messages_widget.dart';
import '../../../widhets/send_whatsapp_message.dart';
import '../../../widhets/registration_form_widget.dart';
import '../../../widhets/request_status_widget.dart';
import '../../../widhets/setting_widget.dart';
import '../../../widhets/send_email.dart';

import '../../../widhets/crop_claim.dart';

class SuperadminpanelView extends GetView<SuperadminpanelController> {
  const SuperadminpanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content Area (always full width)
          _buildContent(context),
          // Overlay when navigation is open
          Obx(
            () => controller.isNavigationOpen.value
                ? GestureDetector(
                    onTap: () => controller.toggleNavigation(),
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  )
                : SizedBox.shrink(),
          ),
          // Side Navigation
          Obx(
            () => AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              left: controller.isNavigationOpen.value ? 0 : -250,
              top: 0,
              bottom: 0,
              width: 250,
              child: _buildSideNavigation(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.supervisor_account,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Super Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Panel',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white24, thickness: 1),
            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(0, Icons.message, 'Admin Messages'),
                  _buildNavItem(1, Icons.send, 'Send Message'),
                  _buildNavItem(2, Icons.email, 'Send Email'),
                  _buildNavItem(3, Icons.agriculture, 'Crop Claim'),
                  _buildNavItem(4, Icons.app_registration, 'Registration'),
                  _buildNavItem(5, Icons.pending_actions, 'Request Status'),
                  _buildNavItem(6, Icons.settings, 'Settings'),

                  // New tabs

                  // _buildNavItem(6, Icons.account_balance, 'Government Schemes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.selectTab(index);
              if (controller.isNavigationOpen.value) {
                controller.toggleNavigation();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      switch (controller.selectedIndex.value) {
        case 0:
          return _buildPageWithHeader(
            context,
            'Admin Messages',
            Icons.message,
            AdminMessagesWidget(),
          );
        case 1:
          return _buildPageWithHeader(
            context,
            'Send Message',
            Icons.send,
            SendWhatsappWidget(),
          );

        case 2:
          return _buildPageWithHeader(
            context,
            'Send Email',
            Icons.email,
            const SendEmailWidget(),
          );
        case 3:
          return _buildPageWithHeader(
            context,
            'Crop Claim',
            Icons.agriculture,
            const CropClaimWidget(),
          );
        case 4:
          return _buildPageWithHeader(
            context,
            'Registration',
            Icons.app_registration,
            RegistrationForm(selectedLanguage: 'en-US'),
          );
        case 5:
          return _buildPageWithHeader(
            context,
            'Request Status',
            Icons.pending_actions,
            RequestStatusWidget(),
          );
        case 6:
          return _buildPageWithHeader(
            context,
            'Settings',
            Icons.settings,
            SettingsWidget(selectedLanguage: 'en-US'),
          );

        // case 6:
        //   return _buildPageWithHeader(
        //     context,
        //     'Government Schemes',
        //     Icons.account_balance,
        //     const GovernmentSchemeWidget(),
        //   );

        default:
          return _buildPageWithHeader(
            context,
            'Admin Messages',
            Icons.message,
            AdminMessagesWidget(),
          );
      }
    });
  }

  Widget _buildPageWithHeader(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Header with hamburger menu
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Hamburger Menu Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.toggleNavigation(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.menu,
                        size: 28,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Icon(icon, color: Color(0xFF2E7D32), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(child: content),
        ],
      ),
    );
  }
}

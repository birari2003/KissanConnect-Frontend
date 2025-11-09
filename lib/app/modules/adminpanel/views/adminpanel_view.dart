import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/adminpanel_controller.dart';
import '../../farmerslist/views/farmerslist_view.dart';
import '../../farmerslist/controllers/farmerslist_controller.dart';
import '../../superadminlist/views/superadminlist_view.dart';
import '../../superadminlist/controllers/superadminlist_controller.dart';
import '../../../widhets/send_email.dart';
import '../../../widhets/send_whatsapp_message.dart';
import '../../../widhets/setting_widget.dart';

class AdminpanelView extends GetView<AdminpanelController> {
  const AdminpanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content Area (always full width)
          _buildContent(context),
          // Overlay when navigation is open
          Obx(() => controller.isNavigationOpen.value
              ? GestureDetector(
                  onTap: () => controller.toggleNavigation(),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                )
              : SizedBox.shrink()),
          // Side Navigation
          Obx(() => AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: controller.isNavigationOpen.value ? 0 : -250,
            top: 0,
            bottom: 0,
            width: 250,
            child: _buildSideNavigation(context),
          )),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A6E9B), // Navy Blue
            Color(0xFF1E5278),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header Section
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Color(0xFF7BB53B), // Green
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'KissanConnect',
                  style: TextStyle(
                    color: Color(0xFF54B5D9), // Light Blue
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          SizedBox(height: 16),
          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() => Column(
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    index: 0,
                    isSelected: controller.selectedIndex.value == 0,
                  ),
                  _buildNavItem(
                    icon: Icons.agriculture_rounded,
                    title: 'Farmers',
                    index: 1,
                    isSelected: controller.selectedIndex.value == 1,
                  ),
                  _buildNavItem(
                    icon: Icons.supervisor_account_rounded,
                    title: 'Super Admins',
                    index: 2,
                    isSelected: controller.selectedIndex.value == 2,
                  ),
                  _buildNavItem(
                    icon: Icons.email_rounded,
                    title: 'Send Email',
                    index: 3,
                    isSelected: controller.selectedIndex.value == 3,
                  ),
                  _buildNavItem(
                    icon: Icons.chat_rounded,
                    title: 'Send WhatsApp',
                    index: 4,
                    isSelected: controller.selectedIndex.value == 4,
                  ),
                  _buildNavItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    index: 5,
                    isSelected: controller.selectedIndex.value == 5,
                  ),
                ],
              )),
            ),
          ),
          // Footer
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF7BB53B),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'admin@kissan.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.changeTab(index);
            if (controller.isNavigationOpen.value) {
              controller.toggleNavigation();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Color(0xFF7BB53B).withOpacity(0.5)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Color(0xFF7BB53B) : Colors.white70,
                  size: 22,
                ),
                SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (controller.selectedIndex.value) {
      case 0:
        return _buildDashboard(context);
      case 1:
        _ensureFarmersListInjected();
        return _buildPageWithHeader(
          context,
          'Farmers',
          Icons.agriculture_rounded,
          const FarmerslistView(embedded: true),
        );
      case 2:
        _ensureSuperAdminListInjected();
        return _buildPageWithHeader(
          context,
          'Super Admins',
          Icons.supervisor_account_rounded,
          const SuperadminlistView(embedded: true),
        );
      case 3:
        return _buildPageWithHeader(
          context,
          'Send Email',
          Icons.email_rounded,
          const SendEmailWidget(),
        );
      case 4:
        return _buildPageWithHeader(
          context,
          'Send WhatsApp',
          Icons.chat_rounded,
          const SendWhatsappWidget(),
        );
      case 5:
        return _buildPageWithHeader(
          context,
          'Settings',
          Icons.settings_rounded,
          const SettingsWidget(selectedLanguage: 'en-US'),
        );
      default:
        return _buildDashboard(context);
    }
  }

  void _ensureFarmersListInjected() {
    if (!Get.isRegistered<FarmerslistController>()) {
      Get.put(FarmerslistController());
    }
  }

  void _ensureSuperAdminListInjected() {
    if (!Get.isRegistered<SuperadminlistController>()) {
      Get.put(SuperadminlistController());
    }
  }

  Widget _buildPageWithHeader(BuildContext context, String title, IconData icon, Widget content) {
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
                        color: Color(0xFF2A6E9B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Icon(icon, color: Color(0xFF2A6E9B), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6E9B),
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

  Widget _buildDashboard(BuildContext context) {
    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Header
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
                        color: Color(0xFF2A6E9B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A6E9B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Welcome back! Here\'s what\'s happening with KissanConnect',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF7BB53B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Color(0xFF7BB53B)),
                      SizedBox(width: 8),
                      Text(
                        'Today',
                        style: TextStyle(
                          color: Color(0xFF7BB53B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards Row 1
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
                      
                      if (isMobile) {
                        // Mobile: 1 card per row
                        return Column(
                          children: [
                            _buildStatCard(
                              title: 'Total Farmers',
                              value: '1,234',
                              icon: Icons.agriculture_rounded,
                              color: Color(0xFF7BB53B),
                              trend: '+12%',
                              trendUp: true,
                            ),
                            SizedBox(height: 16),
                            _buildStatCard(
                              title: 'Super Admins',
                              value: '45',
                              icon: Icons.supervisor_account_rounded,
                              color: Color(0xFF2A6E9B),
                              trend: '+3',
                              trendUp: true,
                            ),
                            SizedBox(height: 16),
                            _buildStatCard(
                              title: 'Pending Requests',
                              value: '28',
                              icon: Icons.pending_actions_rounded,
                              color: Color(0xFFF4B23B),
                              trend: '-5',
                              trendUp: false,
                            ),
                            SizedBox(height: 16),
                            _buildStatCard(
                              title: 'Approved Today',
                              value: '156',
                              icon: Icons.check_circle_rounded,
                              color: Color(0xFF54B5D9),
                              trend: '+18%',
                              trendUp: true,
                            ),
                          ],
                        );
                      } else if (isTablet) {
                        // Tablet: 2 cards per row
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Total Farmers',
                                    value: '1,234',
                                    icon: Icons.agriculture_rounded,
                                    color: Color(0xFF7BB53B),
                                    trend: '+12%',
                                    trendUp: true,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Super Admins',
                                    value: '45',
                                    icon: Icons.supervisor_account_rounded,
                                    color: Color(0xFF2A6E9B),
                                    trend: '+3',
                                    trendUp: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Pending Requests',
                                    value: '28',
                                    icon: Icons.pending_actions_rounded,
                                    color: Color(0xFFF4B23B),
                                    trend: '-5',
                                    trendUp: false,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Approved Today',
                                    value: '156',
                                    icon: Icons.check_circle_rounded,
                                    color: Color(0xFF54B5D9),
                                    trend: '+18%',
                                    trendUp: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        // Desktop: 4 cards per row
                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Farmers',
                                value: '1,234',
                                icon: Icons.agriculture_rounded,
                                color: Color(0xFF7BB53B),
                                trend: '+12%',
                                trendUp: true,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Super Admins',
                                value: '45',
                                icon: Icons.supervisor_account_rounded,
                                color: Color(0xFF2A6E9B),
                                trend: '+3',
                                trendUp: true,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Pending Requests',
                                value: '28',
                                icon: Icons.pending_actions_rounded,
                                color: Color(0xFFF4B23B),
                                trend: '-5',
                                trendUp: false,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Approved Today',
                                value: '156',
                                icon: Icons.check_circle_rounded,
                                color: Color(0xFF54B5D9),
                                trend: '+18%',
                                trendUp: true,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: 24),
                  // Request Status Section
                  Text(
                    'Request Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6E9B),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRequestCard(
                          title: 'Approved',
                          count: '2,456',
                          icon: Icons.check_circle,
                          color: Color(0xFF7BB53B),
                          compact: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildRequestCard(
                          title: 'Rejected',
                          count: '123',
                          icon: Icons.cancel,
                          color: Colors.red,
                          compact: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildRequestCard(
                          title: 'Pending',
                          count: '28',
                          icon: Icons.hourglass_empty,
                          color: Color(0xFFF4B23B),
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Location Coverage Section
                  Text(
                    'Geographic Coverage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6E9B),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLocationCard(
                          title: 'States',
                          count: '15',
                          icon: Icons.map_rounded,
                          color: Color(0xFF2A6E9B),
                          compact: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildLocationCard(
                          title: 'Cities',
                          count: '234',
                          icon: Icons.location_city_rounded,
                          color: Color(0xFF54B5D9),
                          compact: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildLocationCard(
                          title: 'Villages',
                          count: '1,567',
                          icon: Icons.home_work_rounded,
                          color: Color(0xFF7BB53B),
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Recent Activity
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history_rounded, color: Color(0xFF2A6E9B)),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A6E9B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildActivityItem(
                          'New farmer registered from Maharashtra',
                          '2 minutes ago',
                          Icons.person_add,
                          Color(0xFF7BB53B),
                        ),
                        _buildActivityItem(
                          'Request approved by Super Admin',
                          '15 minutes ago',
                          Icons.check_circle,
                          Color(0xFF54B5D9),
                        ),
                        _buildActivityItem(
                          'Email sent to 150 farmers',
                          '1 hour ago',
                          Icons.email,
                          Color(0xFFF4B23B),
                        ),
                        _buildActivityItem(
                          'New village added: Shirpur',
                          '3 hours ago',
                          Icons.add_location,
                          Color(0xFF2A6E9B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendUp
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: trendUp ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: trendUp ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A6E9B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    bool compact = false,
  }) {
    final double pad = compact ? 16 : 20;
    final double iconSize = compact ? 28 : 40;
    final double valueSize = compact ? 24 : 32;
    final double titleSize = compact ? 12 : 14;
    final double spacing = compact ? 8 : 12;
    return Container(
      padding: EdgeInsets.all(pad),
      constraints: BoxConstraints(minHeight: compact ? 120 : 150),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(height: spacing),
          Text(
            count,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    bool compact = false,
  }) {
    final double pad = compact ? 16 : 20;
    final double iconSize = compact ? 28 : 40;
    final double valueSize = compact ? 24 : 32;
    final double titleSize = compact ? 12 : 14;
    final double spacing = compact ? 8 : 12;
    return Container(
      padding: EdgeInsets.all(pad),
      constraints: BoxConstraints(minHeight: compact ? 120 : 150),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: iconSize),
          SizedBox(height: spacing),
          Text(
            count,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
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
                        color: Color(0xFF2A6E9B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6E9B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 80, color: Color(0xFF2A6E9B).withOpacity(0.3)),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6E9B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This section is under development',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

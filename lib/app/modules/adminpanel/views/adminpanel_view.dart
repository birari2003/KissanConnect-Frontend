import 'package:flutter/material.dart';
import '../../../widhets/complaintRecived.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/adminpanel_controller.dart';
import '../../farmerslist/views/farmerslist_view.dart';
import '../../../utils/ui_utils.dart';
import '../../farmerslist/controllers/farmerslist_controller.dart';
import '../../superadminlist/views/superadminlist_view.dart';
import '../../superadminlist/controllers/superadminlist_controller.dart';
import '../../../widhets/send_email.dart';
import '../../../widhets/send_whatsapp_message.dart';
import '../../../widhets/government_schema.dart';
import '../../../widhets/crop_claim.dart';
import '../../../widhets/createJobApplication.dart';
import '../../../widhets/global_chatbot_widget.dart';
import '../../history/views/history_view.dart';
import '../../history/controllers/history_controller.dart';
import './bulk_add_farmers_view.dart';
import '../controllers/bulk_add_farmers_controller.dart';
import './nursery_management_view.dart';
import '../controllers/nursery_management_controller.dart';

class AdminpanelView extends GetView<AdminpanelController> {
  const AdminpanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlobalChatbotWidget(
        child: Stack(
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
            Color(0xFF2E7D32), // Green
            Color(0xFF7BB53B),
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
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Image(
                    image: AssetImage('assets/images/smartshetkari.png'),
                    fit: BoxFit.contain,
                    height: 80,
                    width: 80,
                  ),
                ),
                SizedBox(height: 12),
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Smart Shetkaari',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255), // Light Green
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
              child: Obx(
                () => Column(
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
                      icon: Icons.account_balance,
                      title: 'Govt Schemes',
                      index: 5,
                      isSelected: controller.selectedIndex.value == 5,
                    ),
                    _buildNavItem(
                      icon: Icons.agriculture,
                      title: 'Crop Claim',
                      index: 6,
                      isSelected: controller.selectedIndex.value == 6,
                    ),
                    _buildNavItem(
                      icon: Icons.work_outline,
                      title: 'Create Job',
                      index: 8,
                      isSelected: controller.selectedIndex.value == 8,
                    ),
                    _buildNavItem(
                      icon: Icons.history,
                      title: 'History',
                      index: 9,
                      isSelected: controller.selectedIndex.value == 9,
                    ),
                    _buildNavItem(
                      icon: Icons.report_problem_rounded,
                      title: 'Complaints & Queries',
                      index: 10,
                      isSelected: controller.selectedIndex.value == 10,
                    ),
                    _buildNavItem(
                      icon: Icons.group_add_rounded,
                      title: 'Bulk Add Farmers',
                      index: 11,
                      isSelected: controller.selectedIndex.value == 11,
                    ),
                    _buildNavItem(
                      icon: Icons.store_rounded,
                      title: 'Nursery Management',
                      index: 12,
                      isSelected: controller.selectedIndex.value == 12,
                    ),
                    _buildNavItem(
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      index: 7,
                      isSelected: controller.selectedIndex.value == 7,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 79, 141, 13),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Text(
                          controller.userName.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Obx(
                        () => Text(
                          controller.userEmail.value,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
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
    return Obx(() {
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
            'Government Schemes',
            Icons.account_balance,
            const GovernmentSchemeWidget(),
          );
        case 6:
          return _buildPageWithHeader(
            context,
            'Crop Claim',
            Icons.agriculture,
            const CropClaimWidget(),
          );
        case 7:
          return _buildPageWithHeader(
            context,
            'Settings',
            Icons.settings_rounded,
            _buildAdminSettings(context),
          );
        case 8:
          return _buildPageWithHeader(
            context,
            'Create Job',
            Icons.work_outline,
            const CreateJobApplication(),
          );
        case 9:
          _ensureHistoryControllerInjected();
          return _buildPageWithHeader(
            context,
            'Communication History',
            Icons.history,
            const HistoryView(),
          );
        case 10:
          return _buildPageWithHeader(
            context,
            'Complaints & Queries',
            Icons.report_problem_rounded,
            const ComplaintReceived(),
          );
        case 11:
          _ensureBulkAddFarmersControllerInjected();
          return _buildPageWithHeader(
            context,
            'Bulk Add Farmers',
            Icons.group_add_rounded,
            const BulkAddFarmersView(),
          );
        case 12:
          _ensureNurseryManagementControllerInjected();
          return _buildPageWithHeader(
            context,
            'Nursery Management',
            Icons.store_rounded,
            const NurseryManagementView(),
          );
        default:
          return _buildDashboard(context);
      }
    });
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

  void _ensureHistoryControllerInjected() {
    if (!Get.isRegistered<HistoryController>()) {
      Get.put(HistoryController());
    }
  }

  void _ensureBulkAddFarmersControllerInjected() {
    if (!Get.isRegistered<BulkAddFarmersController>()) {
      Get.put(BulkAddFarmersController());
    }
  }

  void _ensureNurseryManagementControllerInjected() {
    if (!Get.isRegistered<NurseryManagementController>()) {
      Get.put(NurseryManagementController());
    }
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
            margin: EdgeInsets.only(top: 10),
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
                Icon(icon, color: Color(0xFF2E7D32), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
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

  Widget _buildDashboard(BuildContext context) {
    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.only(top: 24),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Welcome back! Here\'s what\'s happening with KissanConnect',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF7BB53B),
                      ),
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
                  Text(
                    'Request Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildRequestCard(
                            title: 'Approved',
                            count: controller.approvedRequests.value.toString(),
                            icon: Icons.check_circle,
                            color: Color(0xFF7BB53B),
                            compact: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _buildRequestCard(
                            title: 'Rejected',
                            count: controller.rejectedRequests.value.toString(),
                            icon: Icons.cancel,
                            color: Colors.red,
                            compact: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _buildRequestCard(
                            title: 'Pending',
                            count: controller.pendingRequests.value.toString(),
                            icon: Icons.hourglass_empty,
                            color: Color(0xFFF4B23B),
                            compact: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      bool isTablet =
                          constraints.maxWidth >= 600 &&
                          constraints.maxWidth < 1024;

                      if (isMobile) {
                        // Mobile: 1 card per row
                        return Column(
                          children: [
                            Obx(
                              () => _buildStatCard(
                                title: 'Total Farmers',
                                value: controller.totalFarmers.value.toString(),
                                icon: Icons.agriculture_rounded,
                                color: Color(0xFF7BB53B),
                                trend: '+12%',
                                trendUp: true,
                              ),
                            ),
                            SizedBox(height: 16),
                            Obx(
                              () => _buildStatCard(
                                title: 'Super Admins',
                                value: controller.totalSuperAdmins.value
                                    .toString(),
                                icon: Icons.supervisor_account_rounded,
                                color: Color(0xFF2E7D32),
                                trend: '+3',
                                trendUp: true,
                              ),
                            ),
                            SizedBox(height: 16),
                            Obx(
                              () => _buildStatCard(
                                title: 'Pending Requests',
                                value: controller.pendingRequests.value
                                    .toString(),
                                icon: Icons.pending_actions_rounded,
                                color: Color(0xFFF4B23B),
                                trend: '-5',
                                trendUp: false,
                              ),
                            ),
                            SizedBox(height: 16),
                            // _buildStatCard(
                            //   title: 'Approved Today',
                            //   value: '1',
                            //   icon: Icons.check_circle_rounded,
                            //   color: Color(0xFF54B5D9),
                            //   trend: '+18%',
                            //   trendUp: true,
                            // ),
                          ],
                        );
                      } else if (isTablet) {
                        // Tablet: 2 cards per row
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildStatCard(
                                      title: 'Total Farmers',
                                      value: controller.totalFarmers.value
                                          .toString(),
                                      icon: Icons.agriculture_rounded,
                                      color: Color(0xFF7BB53B),
                                      trend: '+12%',
                                      trendUp: true,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Obx(
                                    () => _buildStatCard(
                                      title: 'Super Admins',
                                      value: controller.totalSuperAdmins.value
                                          .toString(),
                                      icon: Icons.supervisor_account_rounded,
                                      color: Color(0xFF2E7D32),
                                      trend: '+3',
                                      trendUp: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildStatCard(
                                      title: 'Pending Requests',
                                      value: controller.pendingRequests.value
                                          .toString(),
                                      icon: Icons.pending_actions_rounded,
                                      color: Color(0xFFF4B23B),
                                      trend: '-5',
                                      trendUp: false,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    title: 'Approved Today',
                                    value: '156',
                                    icon: Icons.check_circle_rounded,
                                    color: Color(0xFF66BB6A),
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
                              child: Obx(
                                () => _buildStatCard(
                                  title: 'Total Farmers',
                                  value: controller.totalFarmers.value
                                      .toString(),
                                  icon: Icons.agriculture_rounded,
                                  color: Color(0xFF7BB53B),
                                  trend: '+12%',
                                  trendUp: true,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Obx(
                                () => _buildStatCard(
                                  title: 'Super Admins',
                                  value: controller.totalSuperAdmins.value
                                      .toString(),
                                  icon: Icons.supervisor_account_rounded,
                                  color: Color(0xFF2E7D32),
                                  trend: '+3',
                                  trendUp: true,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Obx(
                                () => _buildStatCard(
                                  title: 'Pending Requests',
                                  value: controller.pendingRequests.value
                                      .toString(),
                                  icon: Icons.pending_actions_rounded,
                                  color: Color(0xFFF4B23B),
                                  trend: '-5',
                                  trendUp: false,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Approved Today',
                                value: '156',
                                icon: Icons.check_circle_rounded,
                                color: Color(0xFF66BB6A),
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

                  // Location Coverage Section
                  Text(
                    'Geographic Coverage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildLocationCard(
                            title: 'States',
                            count: controller.totalStates.value.toString(),
                            icon: Icons.map_rounded,
                            color: Color(0xFF2E7D32),
                            compact: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _buildLocationCard(
                            title: 'Districts',
                            count: controller.totalDistricts.value.toString(),
                            icon: Icons.location_city_rounded,
                            color: Color(0xFF66BB6A),
                            compact: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _buildLocationCard(
                            title: 'Talukas',
                            count: controller.totalTalukas.value.toString(),
                            icon: Icons.home_work_rounded,
                            color: Color(0xFF7BB53B),
                            compact: true,
                          ),
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
                            Icon(
                              Icons.history_rounded,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
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
                          Color(0xFF66BB6A),
                        ),
                        _buildActivityItem(
                          'Email sent to 1 farmers',
                          '1 hour ago',
                          Icons.email,
                          Color(0xFFF4B23B),
                        ),
                        _buildActivityItem(
                          'New village added: Shirpur',
                          '3 hours ago',
                          Icons.add_location,
                          Color(0xFF2E7D32),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        height: 1.1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: trendUp
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendUp
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: trendUp ? Colors.green : Colors.red,
                            size: 14,
                          ),
                          SizedBox(width: 2),
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
              ],
            ),
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
          colors: [color, color.withOpacity(0.7)],
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

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
            margin: EdgeInsets.only(top: 24),
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
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
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 80,
                    color: Color(0xFF2E7D32).withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This section is under development',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSettings(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Profile Section
          _buildAdminProfileCard(),
          SizedBox(height: 24),

          // Preferences Section
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 12),
          Container(
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
              children: [
                // _buildSettingTile(
                //   icon: Icons.notifications_outlined,
                //   title: 'Push Notifications',
                //   subtitle: 'Receive updates on new queries',
                //   trailing: Switch(
                //     value: true,
                //     onChanged: (value) {},
                //     activeColor: Color(0xFF2E7D32),
                //   ),
                // ),
                Divider(height: 1, indent: 70),
                _buildSettingTile(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Get email alerts for complaints',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // App Information Section
          Text(
            'App Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 12),
          Container(
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
              children: [
                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: 'Version 1.0.0',
                  trailing: SizedBox.shrink(),
                ),
                Divider(height: 1, indent: 70),
                _buildSettingTile(
                  icon: Icons.update_outlined,
                  title: 'Last Updated',
                  subtitle: 'December 2025',
                  trailing: SizedBox.shrink(),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Help & Support Section
          // Text(
          //   'Help & Support',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: Color(0xFF2E7D32),
          //   ),
          // ),
          // SizedBox(height: 12),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(16),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.05),
          //         blurRadius: 10,
          //         offset: Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     children: [
          //       _buildSettingTile(
          //         icon: Icons.help_outline,
          //         title: 'Help Center',
          //         subtitle: 'Get help and support',
          //         trailing: Icon(
          //           Icons.arrow_forward_ios,
          //           size: 16,
          //           color: Colors.grey,
          //         ),
          //         onTap: () {},
          //       ),
          //       Divider(height: 1, indent: 70),
          //       _buildSettingTile(
          //         icon: Icons.privacy_tip_outlined,
          //         title: 'Privacy Policy',
          //         subtitle: 'Read our privacy policy',
          //         trailing: Icon(
          //           Icons.arrow_forward_ios,
          //           size: 16,
          //           color: Colors.grey,
          //         ),
          //         onTap: () {},
          //       ),
          //       Divider(height: 1, indent: 70),
          //       _buildSettingTile(
          //         icon: Icons.description_outlined,
          //         title: 'Terms of Service',
          //         subtitle: 'Read terms and conditions',
          //         trailing: Icon(
          //           Icons.arrow_forward_ios,
          //           size: 16,
          //           color: Colors.grey,
          //         ),
          //         onTap: () {},
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: 24),

          // Logout Button
          _buildLogoutButton(context),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Color(0xFF2E7D32), size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProfileCard() {
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
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 35,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value.isEmpty
                        ? 'Admin User'
                        : controller.userName.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.userEmail.value.isEmpty
                        ? 'admin@kissanconnect.com'
                        : controller.userEmail.value,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Get.offAllNamed('/loginsignup');

              UiUtils.showSuccessSnackbar('Success', 'Logged out successfully');
            } catch (e) {
              print('Error during logout: $e');
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 22),
            SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

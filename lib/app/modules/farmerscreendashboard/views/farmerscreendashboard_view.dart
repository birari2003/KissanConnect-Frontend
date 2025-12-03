import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/farmerscreendashboard_controller.dart';
import '../../../widhets/registration_form_widget.dart';
import '../../../widhets/setting_widget.dart';
import '../../../widhets/crop_claim.dart';
import '../../../widhets/sellCrop.dart';
import '../../../widhets/query_popup.dart';
import '../../../widhets/cropList.dart';
import '../../../widhets/govSchema.dart';
import '../../../widhets/jobApplication.dart';
import 'package:flutter_translate/flutter_translate.dart';

class FarmerscreendashboardView
    extends GetView<FarmerscreendashboardController> {
  const FarmerscreendashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    print('DEBUG: --- Dashboard Build Start ---');
    print('DEBUG: Locale: ${LocalizedApp.of(context).delegate.currentLocale}');
    print('DEBUG: Key "app_title": ${translate('app_title')}');
    print('DEBUG: Key "welcome_back": ${translate('welcome_back')}');
    print('DEBUG: Key "dashboard": ${translate('dashboard')}');
    print('DEBUG: Key "my_profile": ${translate('my_profile')}');
    print('DEBUG: Key "role_admin": ${translate('role_admin')}');
    print('DEBUG: --- Dashboard Build End ---');

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
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF2E8B57), const Color(0xFF5CC96F)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: controller.farmerPhoto.value.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              'http://192.168.43.43:5000/uploads/${controller.farmerPhoto.value}',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.agriculture,
                                  color: Color(0xFF2E8B57),
                                  size: 56,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.agriculture,
                            color: Color(0xFF2E8B57),
                            size: 56,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    controller.farmerName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translate('app_title'),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 16),
          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () => Column(
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard,
                      title: translate('dashboard'),
                      index: 0,
                      isSelected: controller.selectedIndex.value == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.app_registration,
                      title: translate('my_profile'),
                      index: 1,
                      isSelected: controller.selectedIndex.value == 1,
                    ),
                    _buildNavItem(
                      icon: Icons.agriculture,
                      title: translate('crop_claim'),
                      index: 2,
                      isSelected: controller.selectedIndex.value == 2,
                    ),
                    _buildNavItem(
                      icon: Icons.storefront,
                      title: translate('sell_crop'),
                      index: 4,
                      isSelected: controller.selectedIndex.value == 4,
                    ),
                    _buildNavItem(
                      icon: Icons.shopping_basket,
                      title: translate('marketplace'),
                      index: 5,
                      isSelected: controller.selectedIndex.value == 5,
                    ),
                    _buildNavItem(
                      icon: Icons.account_balance,
                      title: translate('gov_schemes'),
                      index: 6,
                      isSelected: controller.selectedIndex.value == 6,
                    ),
                    _buildNavItem(
                      icon: Icons.work,
                      title: translate('jobs'),
                      index: 7,
                      isSelected: controller.selectedIndex.value == 7,
                    ),
                    _buildNavItem(
                      icon: Icons.settings,
                      title: translate('settings'),
                      index: 3,
                      isSelected: controller.selectedIndex.value == 3,
                    ),
                  ],
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.5)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 14),
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
          return _buildPageWithHeader(
            context,
            translate('dashboard'),
            Icons.dashboard,
            _buildDashboardTab(),
          );
        case 1:
          return _buildPageWithHeader(
            context,
            translate('my_profile'),
            Icons.app_registration,
            _buildRegistrationTab(),
          );
        case 2:
          return _buildPageWithHeader(
            context,
            translate('crop_claim'),
            Icons.agriculture,
            _buildCropClaimTab(),
          );
        case 3:
          return _buildPageWithHeader(
            context,
            translate('settings'),
            Icons.settings,
            _buildSettingsTab(),
          );
        case 4:
          return _buildPageWithHeader(
            context,
            translate('sell_crop'),
            Icons.storefront,
            _buildSellCropTab(),
          );
        case 5:
          return _buildPageWithHeader(
            context,
            translate('marketplace'),
            Icons.shopping_basket,
            _buildMarketplaceTab(),
          );
        case 6:
          return _buildPageWithHeader(
            context,
            translate('government_schemes'),
            Icons.account_balance,
            const GovSchema(),
          );
        case 7:
          return _buildPageWithHeader(
            context,
            translate('job_applications'),
            Icons.work,
            const JobApplication(),
          );
        default:
          return _buildPageWithHeader(
            context,
            translate('dashboard'),
            Icons.dashboard,
            _buildDashboardTab(),
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
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Header with hamburger menu
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
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
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.menu,
                        size: 28,
                        color: Color(0xFF2E8B57),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(icon, color: const Color(0xFF2E8B57), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E8B57),
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

  Widget _buildDashboardTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5CC96F).withOpacity(0.05),
            const Color(0xFF3C9ED0).withOpacity(0.05),
            const Color(0xFFFFC300).withOpacity(0.02),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  _buildMessagesSection(),
                  const SizedBox(height: 24),
                  _buildRequestStatusSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
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
          translate('app_title'),
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
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -50,
                bottom: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 800),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2E8B57), const Color(0xFF5CC96F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E8B57).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Obx(
                      () => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          image: controller.farmerPhoto.value.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    'http://192.168.43.43:5000/uploads/${controller.farmerPhoto.value}',
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: controller.farmerPhoto.value.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translate('welcome_back'),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.farmerName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(
                            () => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.farmLocation.value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.message, color: Color(0xFF2E8B57), size: 24),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        translate('messages_from_admin'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D323A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Ask Your Query Button
              ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(QueryPopup());
                },
                icon: Icon(Icons.question_answer, size: 18),
                label: Text(translate('ask_query')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E8B57),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            // Loading state
            if (controller.isLoadingMessages.value) {
              return Container(
                padding: EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2E8B57)),
                      SizedBox(height: 12),
                      Text(
                        translate('loading_messages'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Empty state
            if (controller.messages.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E8B57).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 48,
                        color: Color(0xFF2E8B57),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      translate('no_new_messages'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D323A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      translate('important_updates'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Messages list
            return Column(
              children: controller.messages.map((message) {
                return _buildMessageCard(message);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessageCard(dynamic message) {
    final messageText = message['message'] ?? 'No message';
    final senderName = message['sender_name'] ?? 'Admin';
    final senderRole = message['sender_role'] ?? 'admin';
    final createdAt = message['created_at'] ?? '';

    // Format date
    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: senderRole == 'super_admin'
                ? Color(0xFF5CC96F)
                : Color(0xFF2E8B57),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (senderRole == 'super_admin'
                                ? Color(0xFF5CC96F)
                                : Color(0xFF2E8B57))
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    senderRole == 'super_admin'
                        ? Icons.admin_panel_settings
                        : Icons.support_agent,
                    color: senderRole == 'super_admin'
                        ? Color(0xFF5CC96F)
                        : Color(0xFF2E8B57),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D323A),
                        ),
                      ),
                      Text(
                        senderRole == 'super_admin' ? 'Super Admin' : 'Admin',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              messageText,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2D323A),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              translate('total'),
              controller.totalRequests.value.toString(),
              Icons.list_alt,
              const Color(0xFF3C9ED0),
              0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              translate('accepted'),
              controller.acceptedRequests.value.toString(),
              Icons.check_circle,
              const Color(0xFF2E8B57),
              100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              translate('pending'),
              controller.pendingRequests.value.toString(),
              Icons.pending,
              const Color(0xFFFFC300),
              200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    int delay,
  ) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double val, child) {
        return Opacity(
          opacity: val,
          child: Transform.scale(
            scale: val,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF2D323A).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('current_request_status'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D323A),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: _buildStatusCard(controller.requestStatus.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(RequestStatus status) {
    switch (status) {
      case RequestStatus.accepted:
        return _buildAcceptedCard();
      case RequestStatus.rejected:
        return _buildRejectedCard();
      case RequestStatus.pending:
        return _buildPendingCard();
    }
  }

  Widget _buildAcceptedCard() {
    return Container(
      key: const ValueKey('accepted'),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2E8B57).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: Color(0xFF2E8B57), size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            translate('request_approved'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E8B57),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translate('request_approved_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedCard() {
    return Container(
      key: const ValueKey('rejected'),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cancel, color: Colors.red, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            translate('request_rejected'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translate('request_rejected_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    return Container(
      key: const ValueKey('pending'),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC300).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC300).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFF8E1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top,
              color: Color(0xFFFFC300),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            translate('request_pending'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFC300),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translate('request_pending_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationTab() {
    // Get the selected language from controller or use default
    final selectedLanguage = controller.selectedLanguage.value;

    return RegistrationForm(selectedLanguage: selectedLanguage);
  }

  Widget _buildSettingsTab() {
    final selectedLanguage = controller.selectedLanguage.value;

    return SettingsWidget(
      selectedLanguage: selectedLanguage,
      onLanguageChanged: (newLanguage) {
        controller.selectedLanguage.value = newLanguage;
      },
    );
  }

  Widget _buildCropClaimTab() {
    return const CropClaimWidget();
  }

  Widget _buildSellCropTab() {
    return const SellCropWidget();
  }

  Widget _buildMarketplaceTab() {
    return const CropListWidget();
  }
}

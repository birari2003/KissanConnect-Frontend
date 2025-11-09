import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/farmerscreendashboard_controller.dart';
import '../../../widhets/registration_form_widget.dart';
import '../../../widhets/setting_widget.dart';

class FarmerscreendashboardView extends GetView<FarmerscreendashboardController> {
  const FarmerscreendashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentTabIndex.value,
        children: [
          _buildDashboardTab(),
          _buildRegistrationTab(),
          _buildSettingsTab(),
        ],
      )),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        selectedItemColor: const Color(0xFF2E8B57),
        unselectedItemColor: const Color(0xFF2D323A).withOpacity(0.4),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration_outlined),
            activeIcon: Icon(Icons.app_registration),
            label: 'Registration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    ));
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
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  _buildStatsCards(),
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
        title: const Text(
          'KisaanConnect',
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
                    colors: [
                      const Color(0xFF2E8B57),
                      const Color(0xFF5CC96F),
                    ],
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                            controller.farmerName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          const SizedBox(height: 2),
                          Obx(() => Row(
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
                          )),
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

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              controller.totalRequests.value.toString(),
              Icons.list_alt,
              const Color(0xFF3C9ED0),
              0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Accepted',
              controller.acceptedRequests.value.toString(),
              Icons.check_circle,
              const Color(0xFF2E8B57),
              100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color, int delay) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Request Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D323A),
                ),
              ),
              // Demo button to cycle through statuses
              TextButton.icon(
                onPressed: controller.simulateStatusChange,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Demo'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E8B57),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _buildStatusCard(controller.requestStatus.value),
          )),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E8B57),
            const Color(0xFF5CC96F),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Request Accepted!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Congratulations! Your request has been approved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Request ID', '#REQ-2024-001', Colors.white),
                const SizedBox(height: 8),
                _buildInfoRow('Approved Date', '09 Nov 2024', Colors.white),
                const SizedBox(height: 8),
                _buildInfoRow('Status', 'Active', Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E8B57),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedCard() {
    return Container(
      key: const ValueKey('rejected'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Request Rejected',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unfortunately, your request was not approved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Request ID', '#REQ-2024-002', Colors.white),
                const SizedBox(height: 8),
                _buildInfoRow('Rejected Date', '08 Nov 2024', Colors.white),
                const SizedBox(height: 8),
                _buildInfoRow('Reason', 'Incomplete Documents', Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Resubmit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    return Container(
      key: const ValueKey('pending'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFC300),
            const Color(0xFFFFD700),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC300).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1500),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Request Pending',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your request is under review. Please wait for approval.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Request ID', '#REQ-2024-003', Colors.white),
                const SizedBox(height: 8),
                _buildInfoRow('Submitted Date', '07 Nov 2024', Colors.white),
                const SizedBox(height: 8),
                _buildInfoRow('Est. Review Time', '2-3 Days', Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Animated progress indicator
          TweenAnimationBuilder(
            duration: const Duration(seconds: 2),
            tween: Tween<double>(begin: 0, end: 0.6),
            builder: (context, double value, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(value * 100).toInt()}% Reviewed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFFC300),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Track Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
}

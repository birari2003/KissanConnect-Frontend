import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/ui_utils.dart';
import '../../../services/adminServices.dart';

class AdminpanelController extends GetxController {
  final AdminService _adminService = AdminService();

  // Observable for tracking selected navigation tab
  final selectedIndex = 0.obs;

  // Observable for tracking side navigation visibility
  final isNavigationOpen = false.obs;

  // User Data
  final userName = 'Admin User'.obs;
  final userEmail = 'admin@kissan.com'.obs;

  // Dashboard statistics observables
  final totalFarmers = 0.obs;
  final totalSuperAdmins = 0.obs;
  final pendingRequests = 0.obs;
  final approvedRequests = 0.obs;
  final rejectedRequests = 0.obs;
  final totalStates = 0.obs;
  final totalDistricts = 0.obs;
  final totalTalukas = 0.obs;
  final isLoadingStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadDashboardStats();
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        userName.value = userData['name'] ?? 'Admin User';
        userEmail.value = userData['email'] ?? 'admin@kissan.com';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Load all dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      isLoadingStats.value = true;

      // Fetch all users to get farmers and super admins count
      final allUsers = await _adminService.getAllUsers();

      // Count farmers and super admins
      totalFarmers.value = allUsers
          .where((user) => user['role'] == 'farmer')
          .length;
      totalSuperAdmins.value = allUsers
          .where((user) => user['role'] == 'super_admin')
          .length;

      // Fetch farmers list to get status counts
      final farmersList = await _adminService.getFarmersList();

      // Count by status
      pendingRequests.value = farmersList
          .where((f) => f['request_status'] == 'pending')
          .length;
      approvedRequests.value = farmersList
          .where((f) => f['request_status'] == 'approved')
          .length;
      rejectedRequests.value = farmersList
          .where((f) => f['request_status'] == 'rejected')
          .length;

      // Fetch location counts
      final states = await _adminService.getStates();
      totalStates.value = states.length;

      // Get total districts and talukas by aggregating from all states
      int districtCount = 0;
      int talukaCount = 0;

      for (var state in states) {
        try {
          final districts = await _adminService.getDistrictsByState(
            state['id'].toString(),
          );
          districtCount += districts.length;

          // Get talukas for each district
          for (var district in districts) {
            try {
              final talukas = await _adminService.getTalukasByDistrict(
                district['id'].toString(),
              );
              talukaCount += talukas.length;
            } catch (e) {
              print(
                'Error fetching talukas for district ${district['id']}: $e',
              );
            }
          }
        } catch (e) {
          print('Error fetching districts for state ${state['id']}: $e');
        }
      }

      totalDistricts.value = districtCount;
      totalTalukas.value = talukaCount;
    } catch (e) {
      print('Error loading dashboard stats: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to load dashboard statistics');
    } finally {
      isLoadingStats.value = false;
    }
  }

  // Method to change the selected tab
  void changeTab(int index) {
    selectedIndex.value = index;
    // Close navigation after selecting a tab
    isNavigationOpen.value = false;
  }

  // Method to toggle navigation drawer
  void toggleNavigation() {
    isNavigationOpen.value = !isNavigationOpen.value;
  }
}

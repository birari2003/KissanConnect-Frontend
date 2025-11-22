import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widhets/subscriptionPopUp.dart';

enum RequestStatus { accepted, rejected, pending }

class FarmerscreendashboardController extends GetxController {
  // Bottom navigation
  final RxInt currentTabIndex = 0.obs;
  // Side navigation
  final RxBool isNavigationOpen = false.obs;
  final RxInt selectedIndex =
      0.obs; // 0: Dashboard, 1: Registration, 2: Crop Claim, 3: Settings

  // Request status - this will determine which scenario to show
  final Rx<RequestStatus> requestStatus = RequestStatus.pending.obs;

  // User data from SharedPreferences
  final RxString farmerName = 'Loading...'.obs;
  final RxString farmerEmail = ''.obs;
  final RxString farmerPhone = ''.obs;
  final RxString farmLocation = 'Loading...'.obs;

  // Sample data for dashboard (can be replaced with real API data later)
  final RxInt totalRequests = 0.obs;
  final RxInt acceptedRequests = 0.obs;
  final RxInt rejectedRequests = 0.obs;
  final RxInt pendingRequests = 0.obs;

  // Language preference
  final RxString selectedLanguage = 'en-US'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _showSubscriptionPopupAfterDelay();
  }

  // Show subscription popup after 10 seconds
  void _showSubscriptionPopupAfterDelay() {
    Future.delayed(const Duration(seconds: 10), () {
      // Check if user is still on the dashboard before showing popup
      if (Get.isRegistered<FarmerscreendashboardController>()) {
        _showSubscriptionPopup();
      }
    });
  }

  void _showSubscriptionPopup() {
    Get.dialog(const SubscriptionPopup(), barrierDismissible: true);
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        // Update user information
        if (userData['name'] != null) {
          farmerName.value = userData['name'];
        } else {
          farmerName.value = 'Farmer';
        }

        if (userData['email'] != null &&
            userData['email'].toString().isNotEmpty) {
          farmerEmail.value = userData['email'];
        }

        if (userData['phone'] != null) {
          farmerPhone.value = userData['phone'];
        }

        // Set farmer status from user data
        if (userData['farmer_status'] != null) {
          final status = userData['farmer_status'].toString().toLowerCase();
          if (status == 'approved') {
            requestStatus.value = RequestStatus.accepted;
          } else if (status == 'rejected') {
            requestStatus.value = RequestStatus.rejected;
          } else {
            requestStatus.value = RequestStatus.pending;
          }
        }

        // Set default location (can be updated when farmer profile is loaded)
        farmLocation.value = 'India';
      } else {
        farmerName.value = 'Farmer';
        farmLocation.value = 'India';
      }
    } catch (e) {
      print('Error loading user data: $e');
      farmerName.value = 'Farmer';
      farmLocation.value = 'India';
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // Side navigation helpers
  void toggleNavigation() {
    isNavigationOpen.value = !isNavigationOpen.value;
  }

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  void changeRequestStatus(RequestStatus status) {
    requestStatus.value = status;
  }

  // Simulate status change for demo purposes
  void simulateStatusChange() {
    final statuses = RequestStatus.values;
    final currentIndex = statuses.indexOf(requestStatus.value);
    final nextIndex = (currentIndex + 1) % statuses.length;
    requestStatus.value = statuses[nextIndex];
  }
}

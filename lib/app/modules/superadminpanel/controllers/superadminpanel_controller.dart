import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/farmerServices.dart';
import '../../../utils/ui_utils.dart';

class SuperadminpanelController extends GetxController {
  final FarmerService _farmerService = FarmerService();

  final selectedIndex = 0.obs;
  final isNavigationOpen = false.obs;

  // User Data
  final userName = 'Super Admin'.obs;

  // Messages
  final messages = <dynamic>[].obs;
  final isLoadingMessages = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadMessages();
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        userName.value = userData['name'] ?? 'Super Admin';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  void toggleNavigation() {
    isNavigationOpen.value = !isNavigationOpen.value;
  }

  // Load messages from API
  Future<void> loadMessages() async {
    try {
      isLoadingMessages.value = true;
      final data = await _farmerService.getMessages();
      messages.value = data;
    } catch (e) {
      print('Error loading messages: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to load dashboard statistics');
    } finally {
      isLoadingMessages.value = false;
    }
  }
}

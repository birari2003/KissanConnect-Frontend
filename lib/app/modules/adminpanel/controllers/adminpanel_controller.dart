import 'package:get/get.dart';

class AdminpanelController extends GetxController {
  // Observable for tracking selected navigation tab
  final selectedIndex = 0.obs;
  
  // Observable for tracking side navigation visibility
  final isNavigationOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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

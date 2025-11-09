import 'package:get/get.dart';

class SuperadminpanelController extends GetxController {
  final selectedIndex = 0.obs;
  final isNavigationOpen = true.obs;

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  void toggleNavigation() {
    isNavigationOpen.value = !isNavigationOpen.value;
  }
}

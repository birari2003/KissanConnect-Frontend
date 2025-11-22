import 'package:get/get.dart';
import '../../../services/farmerServices.dart';

class SuperadminpanelController extends GetxController {
  final FarmerService _farmerService = FarmerService();

  final selectedIndex = 0.obs;
  final isNavigationOpen = false.obs;

  // Messages
  final messages = <dynamic>[].obs;
  final isLoadingMessages = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
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
      Get.snackbar(
        'Error',
        'Failed to load messages: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }
}

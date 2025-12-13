import 'package:get/get.dart';
import '../services/farmerServices.dart';

class SubscriptionController extends GetxController {
  final FarmerService _farmerService = FarmerService();

  final isSubscribed = false.obs;
  final isLoading = false.obs;
  final subscriptionData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    isLoading.value = true;
    try {
      final response = await _farmerService.getPaymentDetails();
      if (response['success'] == true) {
        isSubscribed.value = response['isSubscribed'] ?? false;
        if (response['subscription'] != null) {
          subscriptionData.value = response['subscription'];
        }
      }
    } catch (e) {
      print('Error checking subscription status: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

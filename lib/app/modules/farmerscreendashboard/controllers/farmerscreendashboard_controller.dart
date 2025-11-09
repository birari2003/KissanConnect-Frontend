import 'package:get/get.dart';

enum RequestStatus { accepted, rejected, pending }

class FarmerscreendashboardController extends GetxController {
  // Bottom navigation
  final RxInt currentTabIndex = 0.obs;
  
  // Request status - this will determine which scenario to show
  final Rx<RequestStatus> requestStatus = RequestStatus.pending.obs;
  
  // Sample data for dashboard
  final RxString farmerName = 'Ramesh Kumar'.obs;
  final RxString farmLocation = 'Maharashtra, India'.obs;
  final RxInt totalRequests = 12.obs;
  final RxInt acceptedRequests = 8.obs;
  final RxInt rejectedRequests = 2.obs;
  final RxInt pendingRequests = 2.obs;
  
  // Language preference
  final RxString selectedLanguage = 'en-US'.obs;

  @override
  void onInit() {
    super.onInit();
    // Simulate different request statuses for demo
    // You can change this based on actual API data
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
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

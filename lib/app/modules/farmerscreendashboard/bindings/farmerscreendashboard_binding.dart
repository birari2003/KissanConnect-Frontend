import 'package:get/get.dart';

import '../controllers/farmerscreendashboard_controller.dart';

class FarmerscreendashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerscreendashboardController>(
      () => FarmerscreendashboardController(),
    );
  }
}

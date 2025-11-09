import 'package:get/get.dart';

import '../controllers/farmerslist_controller.dart';

class FarmerslistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerslistController>(
      () => FarmerslistController(),
    );
  }
}

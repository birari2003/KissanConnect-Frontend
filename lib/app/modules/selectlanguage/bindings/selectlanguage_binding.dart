import 'package:get/get.dart';

import '../controllers/selectlanguage_controller.dart';

class SelectlanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectlanguageController>(
      () => SelectlanguageController(),
    );
  }
}

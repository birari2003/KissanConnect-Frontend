import 'package:get/get.dart';

import '../controllers/superadminlist_controller.dart';

class SuperadminlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperadminlistController>(
      () => SuperadminlistController(),
    );
  }
}

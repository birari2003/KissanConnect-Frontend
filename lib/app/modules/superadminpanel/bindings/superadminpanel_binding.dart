import 'package:get/get.dart';

import '../controllers/superadminpanel_controller.dart';

class SuperadminpanelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperadminpanelController>(
      () => SuperadminpanelController(),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/loginsignup_controller.dart';

class LoginsignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginsignupController>(
      () => LoginsignupController(),
    );
  }
}

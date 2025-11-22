import 'package:get/get.dart';

import '../controllers/paymentgetway_controller.dart';

class PaymentgetwayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentgetwayController>(
      () => PaymentgetwayController(),
    );
  }
}

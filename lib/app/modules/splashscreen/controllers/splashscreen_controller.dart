import 'dart:async';
import 'package:get/get.dart';
import 'package:kissan_connect/app/routes/app_pages.dart';

class SplashScreenController extends GetxController {
  // Duration for splash screen before navigating
  final int splashDuration = 3500;

  @override
  void onInit() {
    super.onInit();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(Duration(milliseconds: splashDuration), () {
      onComplete();
    });
  }

  void onComplete() {
    Get.offAllNamed(
      Routes.SELECTLANGUAGE,
      arguments: null,
    );
  }
}

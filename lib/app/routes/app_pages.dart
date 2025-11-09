import 'package:get/get.dart';

import '../modules/adminpanel/bindings/adminpanel_binding.dart';
import '../modules/adminpanel/views/adminpanel_view.dart';
import '../modules/farmerscreendashboard/bindings/farmerscreendashboard_binding.dart';
import '../modules/farmerscreendashboard/views/farmerscreendashboard_view.dart';
import '../modules/farmerslist/bindings/farmerslist_binding.dart';
import '../modules/farmerslist/views/farmerslist_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/loginsignup/bindings/loginsignup_binding.dart';
import '../modules/loginsignup/views/loginsignup_view.dart';
import '../modules/selectlanguage/bindings/selectlanguage_binding.dart';
import '../modules/selectlanguage/views/selectlanguage_view.dart';
import '../modules/splashscreen/bindings/splashscreen_binding.dart';
import '../modules/splashscreen/views/splashscreen_view.dart';
import '../modules/superadminlist/bindings/superadminlist_binding.dart';
import '../modules/superadminlist/views/superadminlist_view.dart';
import '../modules/superadminpanel/bindings/superadminpanel_binding.dart';
import '../modules/superadminpanel/views/superadminpanel_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SUPERADMINPANEL;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.SELECTLANGUAGE,
      page: () => SelectlanguageView(),
      binding: SelectlanguageBinding(),
    ),
    GetPage(
      name: _Paths.LOGINSIGNUP,
      page: () => const LoginsignupView(),
      binding: LoginsignupBinding(),
    ),
    GetPage(
      name: _Paths.FARMERSCREENDASHBOARD,
      page: () => const FarmerscreendashboardView(),
      binding: FarmerscreendashboardBinding(),
    ),
    GetPage(
      name: _Paths.ADMINPANEL,
      page: () => const AdminpanelView(),
      binding: AdminpanelBinding(),
    ),
    GetPage(
      name: _Paths.FARMERSLIST,
      page: () => const FarmerslistView(),
      binding: FarmerslistBinding(),
    ),
    GetPage(
      name: _Paths.SUPERADMINLIST,
      page: () => const SuperadminlistView(),
      binding: SuperadminlistBinding(),
    ),
    GetPage(
      name: _Paths.SUPERADMINPANEL,
      page: () => const SuperadminpanelView(),
      binding: SuperadminpanelBinding(),
    ),
  ];
}

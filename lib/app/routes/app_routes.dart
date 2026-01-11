import 'package:driveresq_app/modules/driver/bindings/driver_binding.dart';
import 'package:driveresq_app/modules/driver/views/driver_dashboard_view.dart';
import 'package:driveresq_app/modules/mechanic/bindings/mechanic_binding.dart';
import 'package:driveresq_app/modules/mechanic/views/mechanic_dashboard_view.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../modules/auth/bindings/auth_bindings.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/splash_view.dart';
import 'app_pages.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(name: Routes.LOGIN, page: () => LoginView()),
    GetPage(
      name: Routes.DRIVER,
      page: () => DriverDashboardView(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: Routes.MECHANIC,
      page: () => MechanicDashboardView(),
      binding: MechanicBinding(),
    ),
  ];
}

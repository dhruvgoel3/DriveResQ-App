import 'package:driveresq_app/modules/driver/bindings/driver_binding.dart';
import 'package:driveresq_app/modules/driver/views/driver_dashboard_view.dart';
import 'package:driveresq_app/modules/mechanic/bindings/mechanic_binding.dart';
import 'package:driveresq_app/modules/mechanic/views/HomePage/mechanic_dashboard_view.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../modules/auth/bindings/auth_bindings.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/views/enter_phone_number_view.dart';
import '../../modules/auth/views/otp_verification_view.dart';
import '../../modules/auth/views/role_selection_view.dart';
import '../../modules/auth/views/splash_view.dart';
import '../../modules/driver/controllers/driver_controller.dart';
import '../../modules/mechanic/controller/mechanic_controller.dart';
import 'app_pages.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.SPLASH, page: () => SplashView()),
    GetPage(name: Routes.ROLE, page: () => RoleSelectionView()),
    GetPage(name: Routes.LOGIN, page: () => PhoneNumberView()),
    GetPage(name: Routes.OTP, page: () => OTPVerificationView()),

    GetPage(name: Routes.DRIVER, page: () => DriverDashboardView() ,binding: DriverBinding()),

    GetPage(name: Routes.MECHANIC, page: () => MechanicDashboardView(),binding: MechanicBinding()),
  ];
}

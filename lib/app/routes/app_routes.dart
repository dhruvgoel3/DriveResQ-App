import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../modules/auth/bindings/auth_bindings.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/role_selection_view.dart';
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
    GetPage(name: Routes.DRIVER, page: () => RoleSelectionView()),
    GetPage(name: Routes.MECHANIC, page: () => RoleSelectionView()),

  ];
}

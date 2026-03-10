import 'package:driveresq_app/utils/role_change/dev_role_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController(), permanent: true);
  runApp(const DriveResQApp());
}

class DriveResQApp extends StatelessWidget {
  const DriveResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DriveResQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialBinding: BindingsBuilder(() {
        Get.put(DevRoleController(), permanent: true);
      }),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}

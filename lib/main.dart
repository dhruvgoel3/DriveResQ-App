import 'package:driveresq_app/utils/role_change/dev_role_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'modules/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔥 main() started");

  await Firebase.initializeApp();
  print("🔥 Firebase initialized");

  Get.put(AuthController(), permanent: true);
  print("🔥 AuthController registered");

  runApp(const DriveResQApp());
  print("🔥 runApp called");
}

class DriveResQApp extends StatelessWidget {
  const DriveResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DriveResQ',
      debugShowCheckedModeBanner: false,

      // 🔥 REGISTER GLOBAL CONTROLLERS HERE
      initialBinding: BindingsBuilder(() {
        Get.put(DevRoleController(), permanent: true);
      }),

      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

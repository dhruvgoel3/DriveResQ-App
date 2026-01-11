import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'modules/auth/bindings/auth_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DriveResQApp());
}

class DriveResQApp extends StatelessWidget {
  const DriveResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DriveResQ',
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

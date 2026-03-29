import 'package:driveresq_app/utils/role_change/dev_role_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashy_flushbar/flashy_flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/notifications/services/fcm_service.dart';
import 'theme/app_theme.dart';

// 🔔 Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(' Background message: ${message.notification?.title}');
  debugPrint(' Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence for better offline UX
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 🔔 Register background handler (sync, won't block)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Get.put(AuthController(), permanent: true);
  runApp(const DriveResQApp());

  // 🔔 Initialize FCM *after* runApp so it doesn't block the UI from rendering.
  // If FCM permission dialog or token fetch hangs, the app still starts.
  try {
    await FCMService.initialize();
  } catch (e) {
    debugPrint('️ FCM initialization failed: $e');
  }
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
      builder: FlashyFlushbarProvider.init(),
      initialBinding: BindingsBuilder(() {
        Get.put(DevRoleController(), permanent: true);
      }),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}

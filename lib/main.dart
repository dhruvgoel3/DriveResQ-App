import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashy_flushbar/flashy_flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/notifications/services/fcm_service.dart';
import 'theme/app_theme.dart';
import 'utils/role_change/dev_role_container.dart';

// 🔔 Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter Error Boundary (prevents red/grey crash screens in release)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError caught: ${details.exceptionAsString()}');
  };

  // Global Platform Asynchronous Error Boundary
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught platform error: $error\n$stack');
    return true; // Handled, prevents app process crash
  };

  // Safe Environment Variables Loading
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Note: .env file not found or failed to load ($e). Using default environment.');
  }

  // Firebase Initialization
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Enable Firestore offline persistence for responsive roadside access
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Register FCM Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  // Inject permanent core controllers
  Get.put(AuthController(), permanent: true);

  runApp(const DriveResQApp());

  // Non-blocking FCM notifications initialization after UI is rendered
  try {
    await FCMService.initialize();
  } catch (e) {
    debugPrint('main: FCMService.initialize non-fatal error: $e');
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
      builder: (context, child) {
        // Friendly release error widget fallback
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Material(
            color: const Color(0xFFF8FAFC),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEA580C),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      kDebugMode
                          ? errorDetails.exceptionAsString()
                          : 'Please restart the app or go back.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        };

        // Combine with FlashyFlushbar overlay provider
        final flushbarInit = FlashyFlushbarProvider.init();
        if (flushbarInit != null) {
          return flushbarInit(context, child);
        }
        return child ?? const SizedBox.shrink();
      },
      initialBinding: BindingsBuilder(() {
        if (kDebugMode) {
          Get.put(DevRoleController(), permanent: true);
        }
      }),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}

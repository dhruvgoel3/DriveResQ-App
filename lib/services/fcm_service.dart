import 'dart:developer';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Background message: ${message.messageId}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'driveresq_high_priority', // id
    'DriveResQ Notifications', // name
    description: 'High priority notifications for DriveResQ', // description
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> initialize() async {
    // 1. Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('FCM Permission Status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
      return;
    }

    // 2. Initialize local notifications for foreground messaging
    await _initLocalNotifications();

    // 3. Handle messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initial message when app opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // 4. Save Token
    await saveFCMToken();

    // 5. Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _updateTokenInFirestore(newToken);
    });
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        log('Local notification tapped: ${details.payload}');
        if (details.payload != null) {
          _navigateFromPayload(details.payload);
        }
      },
    );

    // Create channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> saveFCMToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _updateTokenInFirestore(token);
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  static Future<void> _updateTokenInFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      log('Saved FCM Token to Firestore');
    } catch (e) {
      log('Error saving FCM token: $e');
    }
  }

  static Future<void> clearFCMToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'fcmToken': FieldValue.delete()},
      );
      log('Cleared FCM token from Firestore');
    } catch (e) {
      log('Error clearing FCM token: $e');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');

      _localNotifications.show(
        id: message.hashCode,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF6C63FF),
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'],
      );
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    log('Message clicked! Routing to: ${message.data['route']}');
    final route = message.data['route'];
    if (route != null) {
      _navigateFromPayload(route);
    }
  }

  static void _navigateFromPayload(String? route) {
    if (route == null || route.isEmpty) return;
    // Navigate to specific routes based on payload
    Get.toNamed(route);
  }
}

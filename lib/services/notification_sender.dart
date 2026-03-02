import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSender {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📢 Send notification to nearby mechanics when driver creates request
  static Future<void> notifyNearbyMechanics({
    required String requestId,
    required String driverId,
    required double driverLat,
    required double driverLng,
    required String problem,
    required String locationName,
  }) async {
    try {
      // Create notification document in Firestore
      // Cloud Function will listen to this and send FCM notifications
      await _firestore.collection('notifications').add({
        'type': 'new_request',
        'requestId': requestId,
        'driverId': driverId,
        'driverLat': driverLat,
        'driverLng': driverLng,
        'problem': problem,
        'locationName': locationName,
        'radius': 20, // 20 km radius
        'targetRole': 'mechanic',
        'title': '🚨 New Assistance Request!',
        'body': 'A driver needs help nearby: $problem at $locationName',
        'data': {
          'route': 'mechanic_requests',
          'requestId': requestId,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      print('✅ Notification queued for nearby mechanics');
    } catch (e) {
      print('❌ Error notifying mechanics: $e');
    }
  }

  // 🎉 Notify driver when mechanic accepts request
  static Future<void> notifyDriverRequestAccepted({
    required String requestId,
    required String driverId,
    required String mechanicId,
    required String mechanicName,
  }) async {
    try {
      // Get driver's FCM token
      final driverDoc = await _firestore.collection('users').doc(driverId).get();
      final fcmToken = driverDoc.data()?['fcmToken'];

      if (fcmToken == null) {
        print('⚠️ Driver has no FCM token');
        return;
      }

      // Create notification
      await _firestore.collection('notifications').add({
        'type': 'request_accepted',
        'requestId': requestId,
        'targetUserId': driverId,
        'fcmToken': fcmToken,
        'title': '✅ Help is on the way!',
        'body': '$mechanicName accepted your request and is coming to help you.',
        'data': {
          'route': 'active_request',
          'requestId': requestId,
          'mechanicId': mechanicId,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      print('✅ Driver notification queued');
    } catch (e) {
      print('❌ Error notifying driver: $e');
    }
  }

  // 🎊 Notify driver when mechanic is near (optional)
  static Future<void> notifyDriverMechanicNearby({
    required String driverId,
    required String mechanicName,
    required String estimatedTime,
  }) async {
    try {
      final driverDoc = await _firestore.collection('users').doc(driverId).get();
      final fcmToken = driverDoc.data()?['fcmToken'];

      if (fcmToken == null) return;

      await _firestore.collection('notifications').add({
        'type': 'mechanic_nearby',
        'targetUserId': driverId,
        'fcmToken': fcmToken,
        'title': '📍 Mechanic Approaching',
        'body': '$mechanicName will arrive in approximately $estimatedTime',
        'data': {
          'route': 'active_request',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });
    } catch (e) {
      print('❌ Error sending nearby notification: $e');
    }
  }

  // ✅ Notify driver when job is completed
  static Future<void> notifyDriverJobCompleted({
    required String driverId,
    required String mechanicName,
  }) async {
    try {
      final driverDoc = await _firestore.collection('users').doc(driverId).get();
      final fcmToken = driverDoc.data()?['fcmToken'];

      if (fcmToken == null) return;

      await _firestore.collection('notifications').add({
        'type': 'job_completed',
        'targetUserId': driverId,
        'fcmToken': fcmToken,
        'title': '🎉 Job Completed!',
        'body': '$mechanicName has marked your job as completed. Thank you for using DriveResQ!',
        'data': {
          'route': 'driver',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });
    } catch (e) {
      print('❌ Error sending completion notification: $e');
    }
  }

  // ❌ Notify driver when mechanic cancels
  static Future<void> notifyDriverRequestCancelled({
    required String driverId,
    required String mechanicName,
  }) async {
    try {
      final driverDoc = await _firestore.collection('users').doc(driverId).get();
      final fcmToken = driverDoc.data()?['fcmToken'];

      if (fcmToken == null) return;

      await _firestore.collection('notifications').add({
        'type': 'request_cancelled',
        'targetUserId': driverId,
        'fcmToken': fcmToken,
        'title': '⚠️ Request Cancelled',
        'body': '$mechanicName had to cancel your request. Looking for another mechanic nearby...',
        'data': {
          'route': 'driver',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });
    } catch (e) {
      print('❌ Error sending cancellation notification: $e');
    }
  }

  // 💬 Send chat message notification (future feature)
  static Future<void> notifyChatMessage({
    required String recipientId,
    required String senderName,
    required String message,
  }) async {
    try {
      final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
      final fcmToken = recipientDoc.data()?['fcmToken'];

      if (fcmToken == null) return;

      await _firestore.collection('notifications').add({
        'type': 'chat_message',
        'targetUserId': recipientId,
        'fcmToken': fcmToken,
        'title': '💬 $senderName',
        'body': message,
        'data': {
          'route': 'chat',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });
    } catch (e) {
      print('❌ Error sending chat notification: $e');
    }
  }
}
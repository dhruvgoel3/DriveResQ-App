import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSender {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> notifyNearbyMechanics({
    required String requestId,
    required String driverId,
    required double driverLat,
    required double driverLng,
    required String problem,
    required String location,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'new_request',
        'recipientId': null, // broadcast
        'recipientRole': 'mechanic',
        'title': '🚨 New Breakdown Request Nearby!',
        'body': 'A driver needs help: $problem at $location',
        'latitude': driverLat,
        'longitude': driverLng,
        'radius': 20, // km
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'new_request',
          'requestId': requestId,
          'driverId': driverId,
          'problem': problem,
          'location': location,
          'route': '/mechanic/requests',
        },
      });
      log('notifyNearbyMechanics Notification created in Firestore');
    } catch (e) {
      log('Error creating notifyNearbyMechanics: $e');
    }
  }

  static Future<void> notifyDriverRequestAccepted({
    required String requestId,
    required String driverId,
    required String mechanicId,
    required String mechanicName,
    required String mechanicPhone,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'request_accepted',
        'recipientId': driverId,
        'title': '✅ Help is on the way!',
        'body': '$mechanicName accepted your request and is coming to help you',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'request_accepted',
          'requestId': requestId,
          'mechanicId': mechanicId,
          'mechanicName': mechanicName,
          'mechanicPhone': mechanicPhone,
          'route': '/driver/active-request',
        },
      });
      log('notifyDriverRequestAccepted Notification created in Firestore');
    } catch (e) {
      log('Error creating notifyDriverRequestAccepted: $e');
    }
  }

  static Future<void> notifyDriverMechanicNearby({
    required String requestId,
    required String driverId,
    required String mechanicName,
    required String eta,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'mechanic_nearby',
        'recipientId': driverId,
        'title': '📍 Mechanic Approaching',
        'body': '$mechanicName is nearby and will arrive in ~$eta',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'mechanic_nearby',
          'requestId': requestId,
          'mechanicName': mechanicName,
          'estimatedTime': eta,
          'route': '/driver/track-mechanic',
        },
      });
    } catch (e) {}
  }

  static Future<void> notifyDriverJobCompleted({
    required String requestId,
    required String driverId,
    required String mechanicName,
    required double totalAmount,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'job_completed',
        'recipientId': driverId,
        'title': '🎉 Job Completed!',
        'body': 'Please review the work and rate $mechanicName',
        'priority': 'normal',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'job_completed',
          'requestId': requestId,
          'totalAmount': totalAmount.toString(),
          'route': '/driver/rate-mechanic',
        },
      });
    } catch (e) {}
  }

  static Future<void> notifyMechanicPaymentReceived({
    required String requestId,
    required String mechanicId,
    required double amount,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'payment_received',
        'recipientId': mechanicId,
        'title': '💰 Payment Received!',
        'body': 'You earned ₹${amount.toStringAsFixed(0)} from this job',
        'priority': 'normal',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'payment_received',
          'requestId': requestId,
          'amount': amount.toString(),
          'route': '/mechanic/earnings',
        },
      });
    } catch (e) {}
  }

  static Future<void> notifyRequestCancelled({
    required String requestId,
    required String recipientId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'request_cancelled',
        'recipientId': recipientId,
        'title': '⚠️ Request Cancelled',
        'body': 'The assistance request has been cancelled: $reason',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'request_cancelled',
          'requestId': requestId,
          'route': '/home',
        },
      });
    } catch (e) {}
  }

  static Future<void> notifyChatMessage({
    required String chatId,
    required String recipientId,
    required String senderName,
    required String message,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'chat_message',
        'recipientId': recipientId,
        'title': senderName,
        'body': _truncate(message, 50),
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'chat_message',
          'chatId': chatId,
          'senderName': senderName,
          'route': '/chat',
        },
      });
    } catch (e) {}
  }

  static Future<void> notifyRatingReceived({
    required String mechanicId,
    required double rating,
    required String review,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'rating_received',
        'recipientId': mechanicId,
        'title': '⭐ New Rating Received',
        'body': 'You received $rating stars from your recent customer',
        'priority': 'normal',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'rating_received',
          'rating': rating.toString(),
          'review': _truncate(review, 30),
          'route': '/mechanic/reviews',
        },
      });
    } catch (e) {}
  }

  static Future<void> notifyVerificationStatus({
    required String mechanicId,
    required String status,
    required String reason,
  }) async {
    try {
      final isApproved = status == 'approved';
      await _firestore.collection('notifications').add({
        'type': isApproved ? 'verification_approved' : 'verification_rejected',
        'recipientId': mechanicId,
        'title': isApproved ? '🎊 Congratulations!' : '❌ Application Update',
        'body': isApproved
            ? 'Your mechanic account has been approved. Start accepting jobs now!'
            : 'Your application needs attention. Reason: $reason',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': isApproved
              ? 'verification_approved'
              : 'verification_rejected',
          'reason': reason,
          'route': isApproved ? '/mechanic/dashboard' : '/mechanic/resubmit',
        },
      });
    } catch (e) {}
  }

  static String _truncate(String str, int len) {
    if (str.length <= len) return str;
    return '${str.substring(0, len)}...';
  }
}

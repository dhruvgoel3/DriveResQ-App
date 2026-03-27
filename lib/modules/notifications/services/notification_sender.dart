import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSender {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── 1. NEW REQUEST → Notify Nearby Mechanics ───
  static Future<void> notifyNearbyMechanics({
    required String requestId,
    required String driverId,
    required double driverLat,
    required double driverLng,
    required String problem,
    required String location,
  }) async {
    try {
      // Fetch all approved mechanics with FCM tokens
      final mechanicsSnap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'mechanic')
          .where('verificationStatus', isEqualTo: 'approved')
          .get();

      int sentCount = 0;
      for (final doc in mechanicsSnap.docs) {
        final mechData = doc.data();
        if (mechData['fcmToken'] == null ||
            (mechData['fcmToken'] as String).isEmpty) continue;

        // Create an individual notification for each mechanic
        await _firestore.collection('notifications').add({
          'type': 'new_request',
          'recipientId': doc.id,
          'recipientRole': 'mechanic',
          'title': 'New Breakdown Request',
          'body': '$problem • $location',
          'isRead': false,
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
        sentCount++;
      }

      log('notifyNearbyMechanics: Sent to $sentCount mechanics');
    } catch (e) {
      log('Error creating notifyNearbyMechanics: $e');
    }
  }

  // ─── 2. REQUEST ACCEPTED → Notify Driver ───
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
        'title': 'Help is on the way!',
        'body': '$mechanicName has accepted your request and is heading to your location.',
        'isRead': false,
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
      log('notifyDriverRequestAccepted: Notification created');
    } catch (e) {
      log('Error creating notifyDriverRequestAccepted: $e');
    }
  }

  // ─── 3. JOB COMPLETED → Notify Driver ───
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
        'title': 'Job Completed',
        'body': '$mechanicName has completed the repair. Total: ₹${totalAmount.toStringAsFixed(0)}. Please rate your experience.',
        'isRead': false,
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'job_completed',
          'requestId': requestId,
          'totalAmount': totalAmount.toString(),
          'route': '/driver/rate-mechanic',
        },
      });
    } catch (e) {
      log('Error creating notifyDriverJobCompleted: $e');
    }
  }

  // ─── 4. RATING RECEIVED → Notify the rated user ───
  static Future<void> notifyRatingReceived({
    required String mechanicId,
    required double rating,
    required String review,
  }) async {
    try {
      final stars = '⭐' * rating.round();
      await _firestore.collection('notifications').add({
        'type': 'rating_received',
        'recipientId': mechanicId,
        'title': 'New Review Received',
        'body': '$stars  ${rating.toStringAsFixed(1)} stars${review.isNotEmpty ? ' — "${_truncate(review, 40)}"' : ''}',
        'isRead': false,
        'priority': 'normal',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'rating_received',
          'rating': rating.toString(),
          'review': _truncate(review, 40),
        },
      });
    } catch (e) {
      log('Error creating notifyRatingReceived: $e');
    }
  }

  // ─── 5. VERIFICATION STATUS → Notify mechanic ───
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
        'title': isApproved ? 'Account Approved' : 'Application Update',
        'body': isApproved
            ? 'Congratulations! Your mechanic account has been approved. You can now start accepting jobs.'
            : 'Your application needs attention: $reason',
        'isRead': false,
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': isApproved ? 'verification_approved' : 'verification_rejected',
          'reason': reason,
          'route': isApproved ? '/mechanic/dashboard' : '/mechanic/resubmit',
        },
      });
    } catch (e) {
      log('Error creating notifyVerificationStatus: $e');
    }
  }

  // ─── REQUEST CANCELLED ───
  static Future<void> notifyRequestCancelled({
    required String requestId,
    required String recipientId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'request_cancelled',
        'recipientId': recipientId,
        'title': 'Request Cancelled',
        'body': 'The assistance request has been cancelled: $reason',
        'isRead': false,
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'request_cancelled',
          'requestId': requestId,
          'route': '/home',
        },
      });
    } catch (e) {
      log('Error creating notifyRequestCancelled: $e');
    }
  }

  // ─── CHAT MESSAGE ───
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
        'body': _truncate(message, 60),
        'isRead': false,
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': {
          'type': 'chat_message',
          'chatId': chatId,
          'senderName': senderName,
        },
      });
    } catch (e) {
      log('Error creating notifyChatMessage: $e');
    }
  }

  // ─── MECHANIC NEARBY ───
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
        'title': 'Mechanic Approaching',
        'body': '$mechanicName is nearby and will arrive in ~$eta',
        'isRead': false,
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
    } catch (e) {
      log('Error creating notifyDriverMechanicNearby: $e');
    }
  }

  // ─── PAYMENT RECEIVED ───
  static Future<void> notifyMechanicPaymentReceived({
    required String requestId,
    required String mechanicId,
    required double amount,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'payment_received',
        'recipientId': mechanicId,
        'title': 'Payment Received',
        'body': 'You earned ₹${amount.toStringAsFixed(0)} from this job.',
        'isRead': false,
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
    } catch (e) {
      log('Error creating notifyMechanicPaymentReceived: $e');
    }
  }

  static String _truncate(String str, int len) {
    if (str.length <= len) return str;
    return '${str.substring(0, len)}...';
  }
}

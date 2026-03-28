import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A robust service responsible for dispatching in-app and push notifications.
///
/// This service acts as a primary interface for creating notification documents
/// in Firestore, which are then processed by background functions or local listeners.
class NotificationSender {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // 📢 BROADCAST & TARGETED ALERTS
  // ---------------------------------------------------------------------------

  /// Broadcasts a breakdown request to all verified mechanics in the area.
  static Future<void> notifyNearbyMechanics({
    required String requestId,
    required String driverId,
    required double driverLat,
    required double driverLng,
    required String problem,
    required String location,
  }) async {
    try {
      final mechanicsGate = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'mechanic')
          .where('verificationStatus', isEqualTo: 'approved')
          .get();

      final batch = _firestore.batch();
      int counter = 0;

      for (final doc in mechanicsGate.docs) {
        final data = doc.data();
        if (data['fcmToken'] == null || (data['fcmToken'] as String).isEmpty)
          continue;

        final notifyRef = _firestore.collection('notifications').doc();
        batch.set(notifyRef, {
          'type': 'new_request',
          'recipientId': doc.id,
          'recipientRole': 'mechanic',
          'title': 'New Breakdown Alert',
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
        counter++;
      }

      if (counter > 0) await batch.commit();
      debugPrint('NotificationSender: Alerted $counter nearby mechanics.');
    } catch (e) {
      debugPrint('NotificationSender Error (nearby): $e');
    }
  }

  /// Notifies a driver when their request is picked up by a mechanic.
  static Future<void> notifyDriverRequestAccepted({
    required String requestId,
    required String driverId,
    required String mechanicId,
    required String mechanicName,
    required String mechanicPhone,
  }) async {
    await _enqueueNotification(
      recipientId: driverId,
      type: 'request_accepted',
      title: 'Help is on the way!',
      body: '$mechanicName is heading to your location right now.',
      payload: {
        'type': 'request_accepted',
        'requestId': requestId,
        'mechanicId': mechanicId,
        'mechanicName': mechanicName,
        'mechanicPhone': mechanicPhone,
        'route': '/driver/active-request',
      },
    );
  }

  /// Informs a driver that the repair has been successfully finalized.
  static Future<void> notifyDriverJobCompleted({
    required String requestId,
    required String driverId,
    required String mechanicName,
    required double totalAmount,
  }) async {
    final body =
        '$mechanicName finished the job. Total: ₹${totalAmount.toStringAsFixed(0)}. Please rate the service.';
    await _enqueueNotification(
      recipientId: driverId,
      type: 'job_completed',
      title: 'Job Completed',
      body: body,
      payload: {
        'type': 'job_completed',
        'requestId': requestId,
        'totalAmount': totalAmount.toString(),
        'route': '/driver/rate-mechanic',
      },
    );
  }

  /// Alerts a user when they receive a new rating or review.
  static Future<void> notifyRatingReceived({
    required String mechanicId,
    required double rating,
    required String review,
  }) async {
    final stars = '⭐' * rating.round();
    final body =
        '$stars ${rating.toStringAsFixed(1)} stars${review.isNotEmpty ? ' — "${_truncate(review, 35)}"' : ''}';

    await _enqueueNotification(
      recipientId: mechanicId,
      type: 'rating_received',
      title: 'Feedback Arrived',
      body: body,
      priority: 'normal',
      payload: {
        'type': 'rating_received',
        'rating': rating.toString(),
        'review': _truncate(review, 100),
      },
    );
  }

  /// Updates a mechanic on their registration approval or rejection.
  static Future<void> notifyVerificationStatus({
    required String mechanicId,
    required String status,
    required String reason,
  }) async {
    final approved = (status == 'approved');
    await _enqueueNotification(
      recipientId: mechanicId,
      type: approved ? 'verification_approved' : 'verification_rejected',
      title: approved ? 'Account Approved' : 'Profile Update Required',
      body: approved
          ? 'Your credentials have been verified. You can now start earning!'
          : 'Status Update: $reason',
      payload: {
        'type': approved ? 'verification_approved' : 'verification_rejected',
        'reason': reason,
        'route': approved ? '/mechanic/dashboard' : '/mechanic/resubmit',
      },
    );
  }

  /// Generic alert for cancelled requests.
  static Future<void> notifyRequestCancelled({
    required String requestId,
    required String recipientId,
    required String reason,
  }) async {
    await _enqueueNotification(
      recipientId: recipientId,
      type: 'request_cancelled',
      title: 'Case Discontinued',
      body: 'The active request was closed: $reason',
      payload: {
        'type': 'request_cancelled',
        'requestId': requestId,
        'route': '/home',
      },
    );
  }

  /// High-priority alert for new chat messages.
  static Future<void> notifyChatMessage({
    required String chatId,
    required String recipientId,
    required String senderName,
    required String message,
  }) async {
    await _enqueueNotification(
      recipientId: recipientId,
      type: 'chat_message',
      title: senderName,
      body: _truncate(message, 60),
      payload: {
        'type': 'chat_message',
        'chatId': chatId,
        'senderName': senderName,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ⚙️ CORE NOTIFICATION ENGINE
  // ---------------------------------------------------------------------------

  /// Centralized logic to insert a notification document into the database.
  static Future<void> _enqueueNotification({
    required String recipientId,
    required String type,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
    String priority = 'high',
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': type,
        'recipientId': recipientId,
        'title': title,
        'body': body,
        'isRead': false,
        'priority': priority,
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'data': payload,
      });
    } catch (e) {
      debugPrint('NotificationSender Engine Failure: $e');
    }
  }

  /// Truncates strings with an ellipsis if they exceed [maxLength].
  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trim()}...';
  }
}

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../notifications/services/notification_sender.dart';
class DriverService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cancels an active request
  static Future<void> cancelActiveRequest(String requestId) async {
    final doc = await _firestore.collection('requests').doc(requestId).get();
    final mechanicId = doc.data()?['mechanicId'];

    await _firestore.collection('requests').doc(requestId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    if (mechanicId != null) {
      await NotificationSender.notifyRequestCancelled(
        requestId: requestId,
        recipientId: mechanicId,
        reason: 'Driver cancelled the request',
      );
    }
  }

  /// Returns a stream of the mechanic's location
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMechanicLocationStream(String mechanicId) {
    return _firestore
        .collection('mechanic_locations')
        .doc(mechanicId)
        .snapshots();
  }

  /// Returns a stream of a request document for real-time status tracking
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getRequestStream(String requestId) {
    return _firestore
        .collection('requests')
        .doc(requestId)
        .snapshots();
  }

  /// Driver approves the mechanic — generates OTP and moves to 'accepted'
  static Future<void> approveMechanic(String requestId) async {
    final code = _generateVerificationCode();
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'accepted',
      'driverApprovedAt': FieldValue.serverTimestamp(),
      'verificationCode': code,
      'verificationAttempts': 0,
      'codeGeneratedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Driver declines the mechanic — resets request to 'open'
  static Future<void> declineMechanic(String requestId) async {
    final doc = await _firestore.collection('requests').doc(requestId).get();
    final mechanicId = doc.data()?['mechanicId'];

    await _firestore.collection('requests').doc(requestId).update({
      'status': 'open',
      'mechanicId': FieldValue.delete(),
      'mechanicPhone': FieldValue.delete(),
      'acceptedAt': FieldValue.delete(),
    });

    if (mechanicId != null) {
      await NotificationSender.notifyRequestCancelled(
        requestId: requestId,
        recipientId: mechanicId,
        reason: 'Driver declined the assignment',
      );
    }
  }

  /// Generate a random 6-digit verification code
  static String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}

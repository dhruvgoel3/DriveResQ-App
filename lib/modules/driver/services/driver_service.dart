import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notifications/services/notification_sender.dart';

/// A service that manages all driver-side operations and interactions with mechanics.
///
/// This class handles request lifecycle events such as cancellations, mechanic
/// approvals, and real-time data streaming for live tracking and status updates.
class DriverService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // 📋 REQUEST MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Cancels an active request and notifies the assigned mechanic if any.
  ///
  /// The status is set to 'cancelled', and a cancellation timestamp is recorded.
  static Future<void> cancelActiveRequest(String requestId) async {
    final snapshot = await _firestore
        .collection('requests')
        .doc(requestId)
        .get();
    final data = snapshot.data();
    final mechanicId = data?['mechanicId'];

    await _firestore.collection('requests').doc(requestId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    if (mechanicId != null) {
      await NotificationSender.notifyRequestCancelled(
        requestId: requestId,
        recipientId: mechanicId,
        reason: 'The driver cancelled the rescue request.',
      );
    }
  }

  /// Finalizes the choice of a mechanic by generating a verification OTP.
  ///
  /// This moves the request status to 'accepted', which triggers the mechanic's
  /// navigation to the driver's location.
  static Future<void> approveMechanic(String requestId) async {
    final otpCode = _generateSecureOtp();

    await _firestore.collection('requests').doc(requestId).update({
      'status': 'accepted',
      'driverApprovedAt': FieldValue.serverTimestamp(),
      'verificationCode': otpCode,
      'verificationAttempts': 0,
      'codeGeneratedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Declines an assigned mechanic and releases the request back to 'open' status.
  ///
  /// This allows other nearby mechanics to see and accept the request again.
  static Future<void> declineMechanic(String requestId) async {
    final snapshot = await _firestore
        .collection('requests')
        .doc(requestId)
        .get();
    final mechanicId = snapshot.data()?['mechanicId'];

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
        reason: 'The driver chose not to proceed with this assignment.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 🛰️ REAL-TIME STREAMS
  // ---------------------------------------------------------------------------

  /// Subscribes to the live location updates of an assigned mechanic.
  static Stream<DocumentSnapshot<Map<String, dynamic>>>
  getMechanicLocationStream(String mechanicId) {
    return _firestore
        .collection('mechanic_locations')
        .doc(mechanicId)
        .snapshots();
  }

  /// Subscribes to the state changes of a specific request.
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getRequestStream(
    String requestId,
  ) {
    return _firestore.collection('requests').doc(requestId).snapshots();
  }

  // ---------------------------------------------------------------------------
  // ⚙️ UTILITIES
  // ---------------------------------------------------------------------------

  /// Generates a random 6-digit one-time password (OTP).
  static String _generateSecureOtp() {
    final random = Random.secure();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../chat/services/chat_service.dart';
import '../../notifications/services/notification_sender.dart';
import '../../../shared/services/connectivity_service.dart';
import '../../../utils/helpers/throttle_helper.dart';

/// A comprehensive service handling all core logic for the Mechanic's operations.
///
/// Responsibilities:
/// - Accepting, cancelling, and completing service requests.
/// - Handling job verifications via secure OTP.
/// - Safely dispatching push notifications and setting up chat rooms.
class MechanicService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // 🚀 JOB MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Accepts a service request on behalf of the current mechanic.
  ///
  /// Throws an [Exception] if the user is unauthorized, already has a job,
  /// or if the request is invalid/taken.
  static Future<void> acceptRequest(String requestId, bool hasActiveJob) async {
    await ThrottleHelper.asyncAction('accept_req_$requestId', () async {
      // 1. Pre-flight checks
      await ConnectivityService.requireConnection();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Unauthenticated: Please log in to accept requests.');
      }
      if (hasActiveJob) {
        throw Exception('Action Denied: You already have an active request.');
      }

      // Attempt to pull the phone from Auth. If absent, it will be pulled from Firestore.
      String? mechanicPhone = user.phoneNumber;
      final mechanicDocContent = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      final mechanicData = mechanicDocContent.data() ?? {};

      mechanicPhone ??= mechanicData['phone'];
      if (mechanicPhone == null || mechanicPhone.isEmpty) {
        throw Exception('Missing Data: Phone number is required to accept jobs.');
      }

      // 2. Request validation
      final requestDoc = await _firestore
          .collection('requests')
          .doc(requestId)
          .get();
      if (!requestDoc.exists) {
        throw Exception('Not Found: This request no longer exists.');
      }

      final requestData = requestDoc.data();
      if (requestData == null || requestData['status'] != 'open') {
        throw Exception(
          'Too Late: This request has already been accepted or closed.',
        );
      }

      if (requestData['driverLat'] == null ||
          requestData['driverPhone'] == null) {
        throw Exception(
          'Data Error: The request has incomplete driver information.',
        );
      }

      // 3. Mark request as accepted
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'mechanic_accepted',
        'mechanicId': user.uid,
        'mechanicPhone': mechanicPhone,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // 4. Fire-and-forget background tasks (Chat & Notifications)
      _initializePostAcceptanceTasks(
        requestId: requestId,
        mechanicId: user.uid,
        mechanicPhone: mechanicPhone,
        mechanicData: mechanicData,
        requestData: requestData,
      );
    })();
  }

  /// Safely cancels an active job, resets the request, and notifies the driver.
  static Future<void> cancelActiveJob(Map<String, dynamic> activeJob) async {
    final jobId = activeJob['id'];
    if (jobId == null) return;
    
    await ThrottleHelper.asyncAction('cancel_job_$jobId', () async {
      await ConnectivityService.requireConnection();

      // Reset the request fields to make it available again
      await _firestore.collection('requests').doc(jobId).update({
        'status': 'open',
        'mechanicId': FieldValue.delete(),
        'mechanicPhone': FieldValue.delete(),
        'acceptedAt': FieldValue.delete(),
        'verificationCode': FieldValue.delete(),
        'verificationAttempts': FieldValue.delete(),
        'codeGeneratedAt': FieldValue.delete(),
      });

      // Notify the driver
      final driverId = activeJob['driverId'];
      if (driverId != null) {
        await NotificationSender.notifyRequestCancelled(
          requestId: jobId,
          recipientId: driverId,
          reason:
              'Mechanic cancelled the request. You can wait for another mechanic.',
        );
      }
    })();
  }

  /// Marks a job as completed and immediately notifies the driver.
  static Future<void> completeJob(Map<String, dynamic> activeJob) async {
    final jobId = activeJob['id'];
    if (jobId == null) return;

    await ThrottleHelper.asyncAction('complete_job_$jobId', () async {
      // Mark completed
      await _firestore.collection('requests').doc(jobId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Notify driver
      final driverId = activeJob['driverId'];
      if (driverId != null) {
        final user = _auth.currentUser;
        final mechName = user?.displayName ?? 'Your Mechanic';

        await NotificationSender.notifyDriverJobCompleted(
          requestId: jobId,
          driverId: driverId,
          mechanicName: mechName,
          totalAmount: 0.0,
        );
      }
    })();
  }

  // ---------------------------------------------------------------------------
  // 🔐 VERIFICATION & SECURITY
  // ---------------------------------------------------------------------------

  /// Finalizes the job phase by verifying the OTP given by the driver.
  /// Returns a user-friendly error string if verification fails, or null on success.
  static Future<String?> verifyAndCompleteJob(
    Map<String, dynamic> activeJob,
    String code,
  ) async {
    final jobId = activeJob['id'];
    if (jobId == null) return 'System Error: Job ID is missing.';

    try {
      final doc = await _firestore.collection('requests').doc(jobId).get();
      if (!doc.exists) return 'The job record was not found in the database.';

      final data = doc.data()!;
      final storedCode = data['verificationCode'] as String?;
      final attempts = (data['verificationAttempts'] ?? 0) as int;

      // Anti-bruteforce check
      if (attempts >= 5) {
        return 'Too many attempts. Ask the driver to generate and share a new code.';
      }

      // Record this attempt
      await _firestore.collection('requests').doc(jobId).update({
        'verificationAttempts': attempts + 1,
      });

      // Verification logic
      if (storedCode == null || storedCode != code) {
        final remaining = 4 - attempts;
        return 'Incorrect code. ${remaining > 0 ? "$remaining attempts remaining." : "No attempts left."}';
      }

      // Success
      await _firestore.collection('requests').doc(jobId).update({
        'status': 'verified',
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      /* print stripped */
      return 'Network or system error. Please try again.';
    }
  }

  // ---------------------------------------------------------------------------
  // ⚙️ PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  /// Executes chat initialization and driver notification as a background
  /// operation so it does not block the acceptance flow UI.
  static Future<void> _initializePostAcceptanceTasks({
    required String requestId,
    required String mechanicId,
    required String mechanicPhone,
    required Map<String, dynamic> mechanicData,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final driverId = requestData['driverId'] ?? '';
      final driverName = requestData['driverName'] ?? 'Driver';
      final mechanicName =
          mechanicData['fullName'] ?? mechanicData['name'] ?? 'Mechanic';

      // Push Notification
      await NotificationSender.notifyDriverRequestAccepted(
        requestId: requestId,
        driverId: driverId,
        mechanicId: mechanicId,
        mechanicName: mechanicName,
        mechanicPhone: mechanicPhone,
      );

      // Create Chat Room
      await ChatService.createChat(
        requestId: requestId,
        driverId: driverId,
        mechanicId: mechanicId,
        driverName: driverName,
        mechanicName: mechanicName,
        driverPhoto: requestData['driverPhoto'] ?? '',
        mechanicPhoto: mechanicData['profilePhotoUrl'] ?? '',
      );
    } catch (e) {
      /* print stripped */
    }
  }
}

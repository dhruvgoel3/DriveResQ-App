import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../chat/services/chat_service.dart';
import '../../notifications/services/notification_sender.dart';
import '../../../shared/services/connectivity_service.dart';

class MechanicService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Accept a request with validation
  static Future<void> acceptRequest(
      String requestId, bool hasActiveJob) async {
    // Check network before accepting
    await ConnectivityService.requireConnection();

    // Validation 1: Check if user is authenticated
    if (_auth.currentUser == null) {
      throw Exception("User not authenticated");
    }

    // Validation 2: Check if mechanic already has an active job
    if (hasActiveJob) {
      throw Exception("You already have an active request.");
    }

    final uid = _auth.currentUser!.uid;
    final mechanicPhone = _auth.currentUser!.phoneNumber;

    if (mechanicPhone == null) {
      throw Exception("Phone number not available");
    }

    // Validation 3: Check if request still exists and is open
    final requestDoc =
        await _firestore.collection('requests').doc(requestId).get();

    if (!requestDoc.exists) {
      throw Exception("Request no longer exists");
    }

    final requestData = requestDoc.data();
    if (requestData == null || requestData['status'] != 'open') {
      throw Exception(
          "This request has already been accepted by another mechanic");
    }

    // Validation 4: Validate driver information
    if (requestData['driverLat'] == null ||
        requestData['driverLng'] == null ||
        requestData['driverPhone'] == null) {
      throw Exception("Request has incomplete information");
    }

    // Accept the request (pending driver approval)
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'mechanic_accepted',
      'mechanicId': uid,
      'mechanicPhone': mechanicPhone,
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    // 💬 Create chat for this request
    try {
      final mechanicDoc = await _firestore.collection('users').doc(uid).get();
      final mechanicData = mechanicDoc.data() ?? {};
      // Notify Driver about Acceptance
      await NotificationSender.notifyDriverRequestAccepted(
        requestId: requestId,
        driverId: requestData['driverId'] ?? '',
        mechanicId: uid,
        mechanicName:
            mechanicData['fullName'] ?? mechanicData['name'] ?? 'Mechanic',
        mechanicPhone: mechanicPhone,
      );

      await ChatService.createChat(
        requestId: requestId,
        driverId: requestData['driverId'] ?? '',
        mechanicId: uid,
        driverName: requestData['driverName'] ?? 'Driver',
        mechanicName:
            mechanicData['fullName'] ?? mechanicData['name'] ?? 'Mechanic',
        driverPhoto: requestData['driverPhoto'] ?? '',
        mechanicPhoto: mechanicData['profilePhotoUrl'] ?? '',
      );
    } catch (chatError) {
      debugPrint('⚠️ Chat creation error (non-blocking): $chatError');
    }
  }

  // ❌ Cancel active job
  static Future<void> cancelActiveJob(Map<String, dynamic> activeJob) async {
    final jobId = activeJob['id'];

    await _firestore.collection('requests').doc(jobId).update({
      'status': 'open',
      'mechanicId': FieldValue.delete(),
      'mechanicPhone': FieldValue.delete(),
      'acceptedAt': FieldValue.delete(),
      'verificationCode': FieldValue.delete(),
      'verificationAttempts': FieldValue.delete(),
      'codeGeneratedAt': FieldValue.delete(),
    });

    // Notify Driver about cancellation
    if (activeJob['driverId'] != null) {
      await NotificationSender.notifyRequestCancelled(
        requestId: jobId,
        recipientId: activeJob['driverId'],
        reason: 'Mechanic cancelled the request',
      );
    }
  }

  // ✅ Complete job
  static Future<void> completeJob(Map<String, dynamic> activeJob) async {
    final jobId = activeJob['id'];

    await _firestore.collection('requests').doc(jobId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    // 🔔 Notify driver job is completed
    if (activeJob['driverId'] != null) {
      final mechanicDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      final mechName = mechanicDoc.data()?['fullName'] ??
          mechanicDoc.data()?['name'] ??
          'Mechanic';

      await NotificationSender.notifyDriverJobCompleted(
        requestId: jobId,
        driverId: activeJob['driverId'],
        mechanicName: mechName,
        totalAmount: 0.0, // Assuming payment happens before or in parallel
      );
    }
  }

  /// Generate a secure 6-digit verification code
  static String _generateVerificationCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Verify the code and complete the job
  /// Returns: null on success, error message on failure
  static Future<String?> verifyAndCompleteJob(
      Map<String, dynamic> activeJob, String code) async {
    final jobId = activeJob['id'];

    try {
      final doc = await _firestore.collection('requests').doc(jobId).get();
      if (!doc.exists) return 'Job not found';

      final data = doc.data()!;
      final storedCode = data['verificationCode'] as String?;
      final attempts = (data['verificationAttempts'] ?? 0) as int;

      if (attempts >= 5) {
        return 'Too many attempts. Ask the driver to share the code again.';
      }

      await _firestore.collection('requests').doc(jobId).update({
        'verificationAttempts': attempts + 1,
      });

      if (storedCode == null || storedCode != code) {
        final remaining = 4 - attempts;
        return 'Wrong code. ${remaining > 0 ? "$remaining attempts left." : "No attempts left."}';
      }

      await _firestore.collection('requests').doc(jobId).update({
        'status': 'verified',
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      debugPrint('Error verifying/completing job: $e');
      return 'Something went wrong. Please try again.';
    }
  }
}

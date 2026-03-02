import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var mechanics = <Map<String, dynamic>>[].obs;
  var selectedMechanic = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;
  var currentFilter = 'pending'.obs;

  // Review state
  final adminNotesController = TextEditingController();
  var checklist = <String, bool>{}.obs;

  static const List<String> verificationChecklist = [
    'All required documents uploaded',
    'Photos are clear and readable',
    'Aadhaar details verified',
    'Details match across documents',
    'No duplicate registration',
    'Identity verified',
    'Address verified',
  ];

  static const List<String> rejectionReasons = [
    'Documents unclear/invalid',
    'Incomplete information',
    'Failed background check',
    'Duplicate registration',
    'Suspicious activity',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize checklist
    for (var item in verificationChecklist) {
      checklist[item] = false;
    }
  }

  @override
  void onClose() {
    adminNotesController.dispose();
    super.onClose();
  }

  Future<void> fetchMechanics(String status) async {
    try {
      isLoading.value = true;
      currentFilter.value = status;

      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'mechanic')
          .where('onboardingCompleted', isEqualTo: true);

      if (status != 'all') {
        query = query.where('verificationStatus', isEqualTo: status);
      }

      final snap = await query.get();

      mechanics.value = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();

      // Sort by submission date (newest first)
      mechanics.sort((a, b) {
        final aTime = a['onboardingSubmittedAt'] as Timestamp?;
        final bTime = b['onboardingSubmittedAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Fetch mechanics error: $e');
    }
  }

  Future<void> loadMechanicDetails(String uid) async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['uid'] = doc.id;
        selectedMechanic.value = data;

        // Load admin notes
        adminNotesController.text = data['adminNotes'] ?? '';

        // Reset checklist
        for (var item in verificationChecklist) {
          checklist[item] = false;
        }
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Load mechanic details error: $e');
    }
  }

  Future<void> approveMechanic(
    String uid,
    String mechanicName, {
    String? welcomeMessage,
  }) async {
    try {
      isLoading.value = true;
      final adminUser = _auth.currentUser;

      // Update mechanic status
      await _firestore.collection('users').doc(uid).update({
        'verificationStatus': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminUser?.uid ?? 'unknown',
        'adminNotes': adminNotesController.text.trim(),
      });

      // Log admin action
      await _firestore.collection('adminActions').add({
        'adminId': adminUser?.uid ?? 'unknown',
        'adminEmail': adminUser?.email ?? 'unknown',
        'mechanicId': uid,
        'mechanicName': mechanicName,
        'action': 'approved',
        'notes': welcomeMessage ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;

      Get.snackbar(
        '✅ Approved',
        '$mechanicName has been approved',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade700,
      );

      // Refresh list
      fetchMechanics(currentFilter.value);
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Approve error: $e');
      Get.snackbar(
        'Error',
        'Failed to approve: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  Future<void> rejectMechanic(
    String uid,
    String mechanicName, {
    required String reason,
    String? notes,
    bool allowResubmission = true,
  }) async {
    try {
      isLoading.value = true;
      final adminUser = _auth.currentUser;

      final currentDoc = await _firestore.collection('users').doc(uid).get();
      final currentCount = currentDoc.data()?['resubmissionCount'] ?? 0;

      await _firestore.collection('users').doc(uid).update({
        'verificationStatus': 'rejected',
        'rejectionReason': reason,
        'rejectionNotes': notes ?? '',
        'allowResubmission': allowResubmission,
        'resubmissionCount': currentCount,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminUser?.uid ?? 'unknown',
        'adminNotes': adminNotesController.text.trim(),
      });

      await _firestore.collection('adminActions').add({
        'adminId': adminUser?.uid ?? 'unknown',
        'adminEmail': adminUser?.email ?? 'unknown',
        'mechanicId': uid,
        'mechanicName': mechanicName,
        'action': 'rejected',
        'reason': reason,
        'notes': notes ?? '',
        'allowResubmission': allowResubmission,
        'timestamp': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;

      Get.snackbar(
        'Rejected',
        '$mechanicName application rejected',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade700,
      );

      fetchMechanics(currentFilter.value);
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Reject error: $e');
      Get.snackbar(
        'Error',
        'Failed to reject: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  Future<void> saveAdminNotes(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'adminNotes': adminNotesController.text.trim(),
      });
      Get.snackbar(
        'Saved',
        'Notes saved',
        backgroundColor: Colors.blue.shade50,
        colorText: Colors.blue,
      );
    } catch (e) {
      debugPrint('❌ Save notes error: $e');
    }
  }

  String getDaysPending(dynamic timestamp) {
    if (timestamp == null) return '?';
    final submitted = (timestamp as Timestamp).toDate();
    final days = DateTime.now().difference(submitted).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final date = (timestamp as Timestamp).toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var totalMechanics = 0.obs;
  var pendingCount = 0.obs;
  var approvedToday = 0.obs;
  var rejectedToday = 0.obs;
  var recentActions = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
    fetchRecentActions();
    _listenToPendingCount();
  }

  void _listenToPendingCount() {
    _firestore
        .collection('users')
        .where('role', isEqualTo: 'mechanic')
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots()
        .listen((snap) {
          pendingCount.value = snap.docs.length;
        });
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;

      // Total mechanics
      final allMechanics = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'mechanic')
          .where('onboardingCompleted', isEqualTo: true)
          .get();
      totalMechanics.value = allMechanics.docs.length;

      // Today's date range
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Approved today
      final approvedDocs = await _firestore
          .collection('adminActions')
          .where('action', isEqualTo: 'approved')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('timestamp', isLessThan: Timestamp.fromDate(todayEnd))
          .get();
      approvedToday.value = approvedDocs.docs.length;

      // Rejected today
      final rejectedDocs = await _firestore
          .collection('adminActions')
          .where('action', isEqualTo: 'rejected')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('timestamp', isLessThan: Timestamp.fromDate(todayEnd))
          .get();
      rejectedToday.value = rejectedDocs.docs.length;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Stats fetch error: $e');
    }
  }

  Future<void> fetchRecentActions() async {
    try {
      final snap = await _firestore
          .collection('adminActions')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      recentActions.value = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Recent actions fetch error: $e');
    }
  }
}

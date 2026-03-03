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

      // Total mechanics (simple single-field query)
      final allMechanics = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'mechanic')
          .get();
      totalMechanics.value = allMechanics.docs
          .where((d) => d.data()['onboardingCompleted'] == true)
          .length;

      // Today's actions — fetch all recent and filter client-side
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      try {
        final allActions = await _firestore
            .collection('adminActions')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .get();

        int approved = 0;
        int rejected = 0;
        for (var doc in allActions.docs) {
          final ts = doc.data()['timestamp'] as Timestamp?;
          if (ts != null && ts.toDate().isAfter(todayStart)) {
            if (doc.data()['action'] == 'approved') approved++;
            if (doc.data()['action'] == 'rejected') rejected++;
          }
        }
        approvedToday.value = approved;
        rejectedToday.value = rejected;
      } catch (_) {
        // adminActions collection may not exist yet
        approvedToday.value = 0;
        rejectedToday.value = 0;
      }

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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller for the Driver History screen.
/// Fetches past requests (completed / cancelled) and joins with
/// completedJobs data for rich detail.
class DriverHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var historyList = <Map<String, dynamic>>[].obs;

  // Stats
  var totalRequests = 0.obs;
  var rescuedCount = 0.obs;
  var cancelledCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;

      // Fetch all non-active requests for this driver
      final snapshot = await _firestore
          .collection('requests')
          .where('driverId', isEqualTo: uid)
          .where('status', whereIn: ['completed', 'cancelled'])
          .get();

      List<Map<String, dynamic>> items = [];
      int completed = 0;
      int cancelled = 0;

      for (var doc in snapshot.docs) {
        final data = {
          ...doc.data(),
          'id': doc.id,
        };

        if (data['status'] == 'completed') {
          completed++;

          // Try to fetch rich completedJobs data
          try {
            final completedDoc = await _firestore
                .collection('completedJobs')
                .doc(doc.id)
                .get();
            if (completedDoc.exists) {
              data['completionData'] = completedDoc.data();
            }
          } catch (e) {
            debugPrint('⚠️ Failed to fetch completion data for ${doc.id}: $e');
          }
        } else if (data['status'] == 'cancelled') {
          cancelled++;
        }

        items.add(data);
      }

      // Sort locally to bypass Firestore composite index requirement
      items.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      historyList.value = items;
      totalRequests.value = items.length;
      rescuedCount.value = completed;
      cancelledCount.value = cancelled;
    } catch (e) {
      debugPrint('❌ Error fetching driver history: $e');
      Get.snackbar('Error', 'Failed to load history');
    } finally {
      isLoading.value = false;
    }
  }
}

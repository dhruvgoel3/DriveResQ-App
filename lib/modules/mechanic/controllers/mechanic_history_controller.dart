import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../utils/helpers/app_snackbar.dart';

/// Controller for the Mechanic History screen.
/// Fetches past requests the mechanic worked on (completed / cancelled)
/// and joins with completedJobs data for detailed reporting.
class MechanicHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = true.obs;
  var historyList = <Map<String, dynamic>>[].obs;

  // Stats
  var totalJobs = 0.obs;
  var completedJobs = 0.obs;
  var totalEarnings = 0.0.obs;
  var totalDistance = 0.0.obs;

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

      // Fetch all non-active requests for this mechanic
      final snapshot = await _firestore
          .collection('requests')
          .where('mechanicId', isEqualTo: uid)
          .where('status', whereIn: ['completed', 'cancelled'])
          .get();

      List<Map<String, dynamic>> items = [];
      int completed = 0;
      double earnings = 0;
      double distance = 0;

      for (var doc in snapshot.docs) {
        final data = {...doc.data(), 'id': doc.id};

        if (data['status'] == 'completed') {
          completed++;

          // Try to fetch rich completedJobs data
          try {
            final completedDoc = await _firestore
                .collection('completedJobs')
                .doc(doc.id)
                .get();
            if (completedDoc.exists) {
              final cData = completedDoc.data()!;
              data['completionData'] = cData;
              earnings += (cData['totalAmount'] ?? 0).toDouble();
              distance += (cData['travelCost'] != null
                  ? (cData['travelCost'] as num).toDouble() /
                        15.0 // ₹15/km
                  : 0);
            }
          } catch (e) {
            /* print stripped */
          }
        }

        items.add(data);
      }

      // Sort locally to bypass Firestore composite index requirement
      items.sort((a, b) {
        final aTime =
            (a['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            (b['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      historyList.value = items;
      totalJobs.value = items.length;
      completedJobs.value = completed;
      totalEarnings.value = earnings;
      totalDistance.value = distance;
    } catch (e) {
      /* print stripped */
      AppSnackbar.error('Failed to load history');
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var hasActiveRequest = false.obs;
  var requestData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    listenToActiveRequest();
  }

  void listenToActiveRequest() {
    final uid = _auth.currentUser!.uid;

    _firestore
        .collection('requests')
        .where('driverId', isEqualTo: uid)
        .where('status', whereIn: ['open', 'accepted', 'verified'])
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            hasActiveRequest.value = true;
            requestData.value = {
              ...snapshot.docs.first.data(),
              'id': snapshot.docs.first.id, // 🔥 IMPORTANT
            };
          } else {
            hasActiveRequest.value = false;
            requestData.value = null;
          }
        });
  }

  Future<void> cancelActiveRequest() async {
    try {
      final data = requestData.value;
      final requestId = data?['id'];

      if (requestId == null || requestId.toString().isEmpty) {
        Get.snackbar('Error', 'No active request found to cancel.');
        return;
      }

      debugPrint('🚫 Cancelling request: $requestId');

      await _firestore
          .collection('requests')
          .doc(requestId)
          .update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
          });

      debugPrint('✅ Request cancelled successfully');
      Get.snackbar('Cancelled', 'Your request has been cancelled.');
    } catch (e) {
      debugPrint('❌ Error cancelling request: $e');
      Get.snackbar('Error', 'Failed to cancel request. Please try again.');
    }
  }
}

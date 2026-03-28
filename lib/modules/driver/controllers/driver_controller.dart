import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/driver_service.dart';

class DriverController extends GetxController {
  var currentIndex = 0.obs;

  /// Scaffold key for opening the drawer from child views.
  GlobalKey<ScaffoldState>? scaffoldKey;

  StreamSubscription? _requestSubscription;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var hasActiveRequest = false.obs;
  var requestData = Rxn<Map<String, dynamic>>();
  var isLoadingRequest = true.obs;

  @override
  void onInit() {
    super.onInit();
    listenToActiveRequest();
  }

  @override
  void onClose() {
    _requestSubscription?.cancel();
    super.onClose();
  }

  void listenToActiveRequest() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('No authenticated user - skipping request listener');
      isLoadingRequest.value = false;
      return;
    }

    isLoadingRequest.value = true;
    _requestSubscription?.cancel();
    _requestSubscription = _firestore
        .collection('requests')
        .where('driverId', isEqualTo: uid)
        .where('status', whereIn: ['open', 'mechanic_accepted', 'accepted', 'verified', 'completed'])
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
            isLoadingRequest.value = false;
            if (snapshot.docs.isNotEmpty) {
              hasActiveRequest.value = true;
              requestData.value = {
                ...snapshot.docs.first.data(),
                'id': snapshot.docs.first.id,
              };
            } else {
              hasActiveRequest.value = false;
              requestData.value = null;
            }
          },
          onError: (error) {
            isLoadingRequest.value = false;
            debugPrint('Error listening to active request: $error');
          },
        );
  }

  Future<void> cancelActiveRequest() async {
    try {
      final data = requestData.value;
      final requestId = data?['id'];

      if (requestId == null || requestId.toString().isEmpty) {
        Get.snackbar('Error', 'No active request found to cancel.');
        return;
      }

      debugPrint('Cancelling request: $requestId');

      await DriverService.cancelActiveRequest(requestId);

      debugPrint('Request cancelled successfully');
      Get.snackbar('Cancelled', 'Your request has been cancelled.');
    } catch (e) {
      debugPrint('Error cancelling request: $e');
      Get.snackbar('Error', 'Failed to cancel request. Please try again.');
    }
  }

  /// Driver approves the mechanic who accepted 
  Future<void> approveMechanic() async {
    try {
      final data = requestData.value;
      final requestId = data?['id'];
      if (requestId == null) {
        Get.snackbar('Error', 'No request found.');
        return;
      }
      await DriverService.approveMechanic(requestId);
      Get.snackbar('Approved!', 'Mechanic confirmed. OTP generated.',
          backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      debugPrint('Error approving mechanic: $e');
      Get.snackbar('Error', 'Failed to approve. Please try again.');
    }
  }

  /// Driver declines the mechanic — request goes back to open
  Future<void> declineMechanic() async {
    try {
      final data = requestData.value;
      final requestId = data?['id'];
      if (requestId == null) {
        Get.snackbar('Error', 'No request found.');
        return;
      }
      await DriverService.declineMechanic(requestId);
      Get.snackbar('Declined', 'Request is open for other mechanics.',
          backgroundColor: const Color(0xFFFF9800).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      debugPrint('Error declining mechanic: $e');
      Get.snackbar('Error', 'Failed to decline. Please try again.');
    }
  }
}

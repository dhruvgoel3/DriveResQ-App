import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/driver_service.dart';
import '../services/location_service.dart';
import '../../../utils/helpers/app_snackbar.dart';

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
  var driverName = 'Driver'.obs;
  var driverPhotoUrl = ''.obs;
  var currentLocationName = 'Live Location'.obs;

  StreamSubscription? _authSubscription;
  StreamSubscription? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    listenToActiveRequest();
    _listenToUserProfile();
    fetchLocation();
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        if (_requestSubscription == null) listenToActiveRequest();
        if (_userSubscription == null) _listenToUserProfile();
      }
    });
  }

  Future<void> fetchLocation() async {
    try {
      final locData = await LocationService.getLocationData();
      final name = locData['locationName']?.toString();
      if (name != null && name.isNotEmpty) {
        currentLocationName.value = name;
      }
    } catch (_) {
      // Graceful fallback without noisy alerts
    }
  }

  void _listenToUserProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _userSubscription?.cancel();
    _userSubscription = _firestore.collection('users').doc(uid).snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data();
        if (data != null) {
          driverName.value = data['fullName'] ?? data['name'] ?? 'Driver';
          driverPhotoUrl.value = data['profilePhotoUrl'] ?? '';
        }
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    cancelSubscription();
    super.onClose();
  }

  void cancelSubscription() {
    _requestSubscription?.cancel();
    _requestSubscription = null;
  }

  void listenToActiveRequest() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoadingRequest.value = false;
      return;
    }

    isLoadingRequest.value = true;
    _requestSubscription?.cancel();
    _requestSubscription = _firestore
        .collection('requests')
        .where('driverId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            isLoadingRequest.value = false;

            const activeStatuses = [
              'open',
              'mechanic_accepted',
              'accepted',
              'verified',
              'completed',
            ];

            final activeDocs = snapshot.docs.where((doc) {
              final status = doc.data()['status'];
              return activeStatuses.contains(status);
            }).toList();

            if (activeDocs.isNotEmpty) {
              // Sort newest first: documents with pending server timestamps are treated as newest
              activeDocs.sort((a, b) {
                final aTs = a.data()['createdAt'] as Timestamp?;
                final bTs = b.data()['createdAt'] as Timestamp?;
                if (aTs == null && bTs == null) return 0;
                if (aTs == null) return -1;
                if (bTs == null) return 1;
                return bTs.compareTo(aTs);
              });

              final latestDoc = activeDocs.first;
              hasActiveRequest.value = true;
              requestData.value = {
                ...latestDoc.data(),
                'id': latestDoc.id,
              };
            } else {
              hasActiveRequest.value = false;
              requestData.value = null;
            }
          },
          onError: (error) {
            debugPrint('DriverController: Error listening to active requests: $error');
            isLoadingRequest.value = false;
          },
        );
  }

  Future<void> cancelActiveRequest() async {
    try {
      final data = requestData.value;
      final requestId = data?['id'];

      if (requestId == null || requestId.toString().isEmpty) {
        AppSnackbar.error('No active request found to cancel.');
        return;
      }


      await DriverService.cancelActiveRequest(requestId);

      AppSnackbar.warning('Your request has been cancelled.', title: 'Cancelled');
    } catch (e) {
      AppSnackbar.error('Failed to cancel request. Please try again.');
    }
  }

  /// Driver approves the mechanic who accepted
  Future<void> approveMechanic() async {
    try {
      final data = requestData.value;
      final requestId = data?['id'];
      if (requestId == null) {
        AppSnackbar.error('No request found.');
        return;
      }
      await DriverService.approveMechanic(requestId);
      AppSnackbar.success('Mechanic confirmed. OTP generated.', title: 'Approved!');
    } catch (e) {
      AppSnackbar.error('Failed to approve. Please try again.');
    }
  }

  /// Driver declines the mechanic — request goes back to open
  Future<void> declineMechanic() async {
    try {
      final data = requestData.value;
      final requestId = data?['id'];
      if (requestId == null) {
        AppSnackbar.error('No request found.');
        return;
      }
      await DriverService.declineMechanic(requestId);
      AppSnackbar.warning(
        'Request is open for other mechanics.',
        title: 'Declined',
      );
    } catch (e) {
      AppSnackbar.error('Failed to decline. Please try again.');
    }
  }
}

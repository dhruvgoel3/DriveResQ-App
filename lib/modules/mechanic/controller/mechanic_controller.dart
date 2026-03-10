import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../driver/services/mechanic_location_service.dart';
import '../../chat/services/chat_service.dart';
import '../../notifications/services/notification_sender.dart';

class MechanicController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Bottom navigation management
  var currentIndex = 0.obs;

  // Tab management (0 = All Requests, 1 = Accepted Requests)
  var selectedTab = 0.obs;

  // Location tracking
  var mechanicLat = 0.0.obs;
  var mechanicLng = 0.0.obs;
  var isLocationLoaded = false.obs;

  // Active job management
  var hasActiveJob = false.obs;
  var activeJob = Rxn<Map<String, dynamic>>();

  // Nearby open requests (15-20 km radius)
  var openRequests = <Map<String, dynamic>>[].obs;

  StreamSubscription? _requestsSubscription;
  StreamSubscription? _activeJobSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeMechanic();
  }

  @override
  void onClose() {
    _requestsSubscription?.cancel();
    _activeJobSubscription?.cancel();
    MechanicLocationService.stopTracking(); // Stop location tracking
    super.onClose();
  }

  // 📍 Initialize mechanic location and listeners
  Future<void> _initializeMechanic() async {
    // Check if user is authenticated
    if (_auth.currentUser == null) {
      Get.snackbar("Error", "User not authenticated. Please login again.");
      return;
    }

    await _getMechanicLocation();
    _listenToActiveJob();
    _listenToNearbyRequests();
  }

  // 📍 Get mechanic's current location
  Future<void> _getMechanicLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Error", "Please enable location services");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Error", "Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Error",
          "Location permission denied permanently. Please enable in settings.",
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      mechanicLat.value = position.latitude;
      mechanicLng.value = position.longitude;
      isLocationLoaded.value = true;

      debugPrint(
        "Mechanic Location: ${mechanicLat.value}, ${mechanicLng.value}",
      );
    } catch (e) {
      debugPrint("Location Error: $e");
      Get.snackbar("Error", "Could not fetch location: $e");
    }
  }

  // 🎧 Listen to mechanic's active job
  void _listenToActiveJob() {
    if (_auth.currentUser == null) return;

    final uid = _auth.currentUser!.uid;

    _activeJobSubscription = _firestore
        .collection('requests')
        .where('mechanicId', isEqualTo: uid)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              hasActiveJob.value = true;
              activeJob.value = {
                ...snapshot.docs.first.data(),
                'id': snapshot.docs.first.id,
              };

              // 🚀 START LOCATION TRACKING when job is active
              MechanicLocationService.startTracking();

              debugPrint("Active job found: ${activeJob.value!['id']}");
            } else {
              hasActiveJob.value = false;
              activeJob.value = null;

              // 🛑 STOP LOCATION TRACKING when no active job
              MechanicLocationService.stopTracking();

              debugPrint("No active job");
            }
          },
          onError: (error) {
            debugPrint("Error listening to active job: $error");
            Get.snackbar("Error", "Failed to load active job");
          },
        );
  }

  // 🎧 Listen to nearby OPEN requests only (Real-time)
  void _listenToNearbyRequests() {
    // FIX: Only show 'open' requests (not accepted ones)
    _requestsSubscription = _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open') // ✅ FIXED: Only open requests
        .snapshots()
        .listen(
          (snapshot) {
            if (!isLocationLoaded.value) {
              openRequests.clear();
              return;
            }

            List<Map<String, dynamic>> nearbyList = [];

            for (var doc in snapshot.docs) {
              final data = doc.data();
              final driverLat = data['driverLat'];
              final driverLng = data['driverLng'];

              // Validate location data
              if (driverLat == null || driverLng == null) {
                debugPrint("Request ${doc.id} has missing location data");
                continue;
              }

              try {
                // Calculate distance
                double distance =
                    Geolocator.distanceBetween(
                      mechanicLat.value,
                      mechanicLng.value,
                      driverLat,
                      driverLng,
                    ) /
                    1000; // Convert to km

                // Only show requests within 20 km
                if (distance <= 20) {
                  nearbyList.add({
                    ...data,
                    'id': doc.id,
                    'distance': distance.toStringAsFixed(1),
                  });
                }
              } catch (e) {
                debugPrint(
                  "Error calculating distance for request ${doc.id}: $e",
                );
                continue;
              }
            }

            // Sort by distance (closest first)
            nearbyList.sort((a, b) {
              try {
                return double.parse(
                  a['distance'],
                ).compareTo(double.parse(b['distance']));
              } catch (e) {
                return 0;
              }
            });

            openRequests.value = nearbyList;
            debugPrint("Found ${nearbyList.length} nearby open requests");
          },
          onError: (error) {
            debugPrint("Error listening to requests: $error");
            Get.snackbar("Error", "Failed to load requests");
          },
        );
  }

  // ✅ Accept a request with validation
  Future<void> acceptRequest(String requestId) async {
    try {
      // Validation 1: Check if user is authenticated
      if (_auth.currentUser == null) {
        Get.snackbar("Error", "User not authenticated");
        return;
      }

      // Validation 2: Check if mechanic already has an active job
      if (hasActiveJob.value) {
        Get.snackbar(
          "Already Busy",
          "You already have an active request. Complete or cancel it first.",
          duration: Duration(seconds: 3),
        );
        return;
      }

      final uid = _auth.currentUser!.uid;
      final mechanicPhone = _auth.currentUser!.phoneNumber;

      if (mechanicPhone == null) {
        Get.snackbar("Error", "Phone number not available");
        return;
      }

      // Validation 3: Check if request still exists and is open (Race condition prevention)
      final requestDoc = await _firestore
          .collection('requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        Get.snackbar("Error", "Request no longer exists");
        return;
      }

      final requestData = requestDoc.data();
      if (requestData == null || requestData['status'] != 'open') {
        Get.snackbar(
          "Request Unavailable",
          "This request has already been accepted by another mechanic",
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Validation 4: Validate driver information
      if (requestData['driverLat'] == null ||
          requestData['driverLng'] == null ||
          requestData['driverPhone'] == null) {
        Get.snackbar("Error", "Request has incomplete information");
        return;
      }

      // ✅ All validations passed - Accept the request
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'accepted',
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

      Get.snackbar(
        "Success",
        "Request accepted! You can now chat with the driver.",
        backgroundColor: Color(0xFF4CAF50).withOpacity(0.9),
        colorText: Colors.white,
      );

      changeInnerTab(1); // Switch to "Accepted Requests" tab

      // Location tracking will auto-start via _listenToActiveJob
      debugPrint("Request $requestId accepted successfully");
    } catch (e) {
      debugPrint("Error accepting request: $e");

      // More specific error messages
      if (e.toString().contains('permission')) {
        Get.snackbar("Error", "You don't have permission to accept requests");
      } else if (e.toString().contains('network')) {
        Get.snackbar("Error", "Network error. Please check your connection");
      } else {
        Get.snackbar("Error", "Failed to accept request. Please try again");
      }
    }
  }

  // ❌ Cancel active job with confirmation
  Future<void> cancelActiveJob() async {
    if (activeJob.value == null) {
      Get.snackbar("Error", "No active job to cancel");
      return;
    }

    try {
      await _firestore
          .collection('requests')
          .doc(activeJob.value!['id'])
          .update({
            'status': 'open',
            'mechanicId': FieldValue.delete(),
            'mechanicPhone': FieldValue.delete(),
            'acceptedAt': FieldValue.delete(),
          });

      // Notify Driver about cancellation
      if (activeJob.value!['driverId'] != null) {
        await NotificationSender.notifyRequestCancelled(
          requestId: activeJob.value!['id'],
          recipientId: activeJob.value!['driverId'],
          reason: 'Mechanic cancelled the request',
        );
      }

      Get.snackbar(
        "Success",
        "Job cancelled successfully",
        backgroundColor: Color(0xFFFF9800).withOpacity(0.9),
        colorText: Colors.white,
      );

      debugPrint("Job cancelled: ${activeJob.value!['id']}");

      // Location tracking will auto-stop via _listenToActiveJob
    } catch (e) {
      debugPrint("Error cancelling job: $e");
      Get.snackbar("Error", "Failed to cancel job: $e");
    }
  }

  // ✅ Complete job with validation
  Future<void> completeJob() async {
    if (activeJob.value == null) {
      Get.snackbar("Error", "No active job to complete");
      return;
    }

    try {
      final jobId = activeJob.value!['id'];

      await _firestore.collection('requests').doc(jobId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // 🔔 Notify driver job is completed
      if (activeJob.value!['driverId'] != null) {
        final mechanicDoc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        final mechName =
            mechanicDoc.data()?['fullName'] ??
            mechanicDoc.data()?['name'] ??
            'Mechanic';

        await NotificationSender.notifyDriverJobCompleted(
          requestId: jobId,
          driverId: activeJob.value!['driverId'],
          mechanicName: mechName,
          totalAmount: 0.0, // Assuming payment happens before or in parallel
        );
      }

      Get.snackbar(
        "Success",
        "Job completed successfully! Great work!",
        backgroundColor: Color(0xFF4CAF50).withOpacity(0.9),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      debugPrint("Job completed: $jobId");

      // Location tracking will auto-stop via _listenToActiveJob
    } catch (e) {
      debugPrint("Error completing job: $e");
      Get.snackbar("Error", "Failed to complete job: $e");
    }
  }

  // Tab switching with animation (All Requests / Accepted Requests)
  void changeInnerTab(int index) {
    selectedTab.value = index;
  }

  // Bottom navigation switching
  void changeTab(int index) {
    currentIndex.value = index;
  }

  // Refresh location manually
  Future<void> refreshLocation() async {
    await _getMechanicLocation();
    Get.snackbar("Success", "Location refreshed");
  }

  // 🆕 Check mechanic's availability
  bool isAvailable() {
    return !hasActiveJob.value && isLocationLoaded.value;
  }
}

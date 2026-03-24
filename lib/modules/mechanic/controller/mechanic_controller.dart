import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../driver/services/mechanic_location_service.dart';
import '../services/mechanic_service.dart';

class MechanicController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Bottom navigation management
  var currentIndex = 0.obs;

  /// Scaffold key for opening the drawer from child views.
  GlobalKey<ScaffoldState>? scaffoldKey;

  // Tab management (0 = All Requests, 1 = Accepted Requests)
  var selectedTab = 0.obs;

  // Location tracking
  var mechanicLat = 0.0.obs;
  var mechanicLng = 0.0.obs;
  var isLocationLoaded = false.obs;
  var locationError = RxnString(); // null = no error, string = error message

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
    MechanicLocationService.stopTracking();
    super.onClose();
  }

  Future<void> _initializeMechanic() async {
    if (_auth.currentUser == null) {
      Get.snackbar("Error", "User not authenticated. Please login again.");
      return;
    }

    await _getMechanicLocation();
    // Always start listeners — even without location, mechanic can see
    // accepted jobs and other UI; distance filtering just won't apply.
    _listenToActiveJob();
    _listenToNearbyRequests();
  }

  /// Get mechanic's current location with fallback accuracy
  Future<void> _getMechanicLocation() async {
    try {
      locationError.value = null;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError.value = "Location services are disabled";
        Get.snackbar(
          "Location Disabled",
          "Please enable location services to see nearby requests",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError.value = "Location permission denied";
          Get.snackbar(
            "Permission Required",
            "Allow location access to see nearby requests",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.9),
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = "Location permission permanently denied";
        Get.snackbar(
          "Permission Required",
          "Please enable location in your device settings",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        return;
      }

      // Try high accuracy first, fall back to medium on failure
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        debugPrint("High accuracy failed, trying medium...");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 10));
      }

      mechanicLat.value = position.latitude;
      mechanicLng.value = position.longitude;
      isLocationLoaded.value = true;
      locationError.value = null;

      debugPrint(
        "Mechanic Location: ${mechanicLat.value}, ${mechanicLng.value}",
      );
    } catch (e) {
      debugPrint("Location Error: $e");
      locationError.value = "Could not fetch location";
      Get.snackbar(
        "Location Error",
        "Could not get your location. Pull down to retry.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  // 🎧 Listen to mechanic's active job
  void _listenToActiveJob() {
    if (_auth.currentUser == null) return;

    final uid = _auth.currentUser!.uid;

    _activeJobSubscription = _firestore
        .collection('requests')
        .where('mechanicId', isEqualTo: uid)
        .where('status', whereIn: ['mechanic_accepted', 'accepted', 'verified'])
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
      await MechanicService.acceptRequest(requestId, hasActiveJob.value);

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
        Get.snackbar("Error", e.toString().replaceFirst('Exception: ', ''));
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
      await MechanicService.cancelActiveJob(activeJob.value!);

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
      await MechanicService.completeJob(activeJob.value!);

      Get.snackbar(
        "Success",
        "Job completed successfully! Great work!",
        backgroundColor: Color(0xFF4CAF50).withOpacity(0.9),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      debugPrint("Job completed: ${activeJob.value!['id']}");

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



  /// Verify the code and complete the job
  /// Returns: null on success, error message on failure
  Future<String?> verifyAndCompleteJob(String code) async {
    if (activeJob.value == null) {
      return 'No active job';
    }

    final jobId = activeJob.value!['id'];
    
    final errorMsg = await MechanicService.verifyAndCompleteJob(activeJob.value!, code);
    
    if (errorMsg == null) {
      Get.snackbar(
        'Verified!',
        'Code verified! Complete the job details now.',
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      debugPrint('Job verified: $jobId');
      return null;
    } else {
      return errorMsg;
    }
  }
}

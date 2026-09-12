import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../driver/services/mechanic_location_service.dart';
import '../services/mechanic_service.dart';
import '../../../utils/helpers/app_snackbar.dart';

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
      AppSnackbar.error('User not authenticated. Please login again.');
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
        AppSnackbar.warning(
          'Please enable location services to see nearby requests',
          title: 'Location Disabled',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError.value = "Location permission denied";
          AppSnackbar.warning(
            'Allow location access to see nearby requests',
            title: 'Permission Required',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = "Location permission permanently denied";
        AppSnackbar.error(
          'Please enable location in your device settings',
          title: 'Permission Required',
        );
        return;
      }

      // Try high accuracy first, fall back to medium on failure
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        ).timeout(const Duration(seconds: 10));
      }

      mechanicLat.value = position.latitude;
      mechanicLng.value = position.longitude;
      isLocationLoaded.value = true;
      locationError.value = null;

    } catch (e) {
      locationError.value = "Could not fetch location";
      AppSnackbar.error(
        'Could not get your location. Pull down to retry.',
        title: 'Location Error',
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

            } else {
              hasActiveJob.value = false;
              activeJob.value = null;

              // 🛑 STOP LOCATION TRACKING when no active job
              MechanicLocationService.stopTracking();

            }
          },
          onError: (error) {
            AppSnackbar.error('Failed to load active job');
          },
        );
  }

  // 🎧 Listen to nearby OPEN requests only (Real-time)
  void _listenToNearbyRequests() {
    // FIX: Only show 'open' requests (not accepted ones)
    final minLat = mechanicLat.value - 0.2; // ~22km boundary
    final maxLat = mechanicLat.value + 0.2;

    _requestsSubscription = _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open') // ✅ FIXED: Only open requests
        .where('driverLat', isGreaterThanOrEqualTo: minLat)
        .where('driverLat', isLessThanOrEqualTo: maxLat)
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
          },
          onError: (error) {
            AppSnackbar.error('Failed to load requests');
          },
        );
  }

  // ✅ Accept a request with validation
  Future<void> acceptRequest(String requestId) async {
    try {
      await MechanicService.acceptRequest(requestId, hasActiveJob.value);

      AppSnackbar.success('Request accepted! You can now chat with the driver.');

      changeInnerTab(1); // Switch to "Accepted Requests" tab

      // Location tracking will auto-start via _listenToActiveJob
    } catch (e) {

      // More specific error messages
      if (e.toString().contains('permission')) {
        AppSnackbar.error("You don't have permission to accept requests");
      } else if (e.toString().contains('network')) {
        AppSnackbar.error('Network error. Please check your connection');
      } else {
        AppSnackbar.error(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ❌ Cancel active job with confirmation
  Future<void> cancelActiveJob() async {
    if (activeJob.value == null) {
      AppSnackbar.error('No active job to cancel');
      return;
    }

    try {
      await MechanicService.cancelActiveJob(activeJob.value!);

      AppSnackbar.warning('Job cancelled successfully', title: 'Cancelled');


      // Location tracking will auto-stop via _listenToActiveJob
    } catch (e) {
      AppSnackbar.error('Failed to cancel job: $e');
    }
  }

  // ✅ Complete job with validation
  Future<void> completeJob() async {
    if (activeJob.value == null) {
      AppSnackbar.error('No active job to complete');
      return;
    }

    try {
      await MechanicService.completeJob(activeJob.value!);

      AppSnackbar.success('Job completed successfully! Great work!');


      // Location tracking will auto-stop via _listenToActiveJob
    } catch (e) {
      AppSnackbar.error('Failed to complete job: $e');
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
    
    // Reboot the stream with the newly anchored bounding box
    _requestsSubscription?.cancel();
    _listenToNearbyRequests();
    
    AppSnackbar.success('Location refreshed');
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

    final errorMsg = await MechanicService.verifyAndCompleteJob(
      activeJob.value!,
      code,
    );

    if (errorMsg == null) {
      AppSnackbar.success(
        'Code verified! Complete the job details now.',
        title: 'Verified!',
      );
      return null;
    } else {
      return errorMsg;
    }
  }
}

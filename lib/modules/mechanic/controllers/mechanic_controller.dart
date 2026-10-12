import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../driver/services/mechanic_location_service.dart';
import '../services/mechanic_service.dart';
import '../../pricing/models/travel_pricing_model.dart';
import '../../pricing/services/pricing_config_service.dart';
import '../../pricing/services/distance_calculation_service.dart';
import '../../../utils/helpers/app_snackbar.dart';
import '../../../utils/role_change/dev_config.dart';

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
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _latestDocs = [];

  StreamSubscription? _requestsSubscription;
  StreamSubscription? _activeJobSubscription;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeMechanic();
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null && _requestsSubscription == null) {
        _initializeMechanic();
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    cancelSubscriptions();
    super.onClose();
  }

  /// Cancels all active Firestore stream subscriptions safely.
  void cancelSubscriptions() {
    _requestsSubscription?.cancel();
    _activeJobSubscription?.cancel();
    _requestsSubscription = null;
    _activeJobSubscription = null;
    try {
      MechanicLocationService.stopTracking();
    } catch (_) {}
  }

  Future<void> _initializeMechanic() async {
    if (_auth.currentUser == null) {
      debugPrint('MechanicController: User not authenticated.');
      return;
    }

    // Start listeners immediately — do not block them waiting for GPS
    _listenToActiveJob();
    _listenToNearbyRequests();
    _getMechanicLocation();
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
      _processOpenRequests();

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
            debugPrint('MechanicController: Error listening to active job: $error');
          },
        );
  }

  void refreshRequests() {
    _requestsSubscription?.cancel();
    _listenToNearbyRequests();
  }

  // 🎧 Listen to nearby OPEN requests only (Real-time)
  void _listenToNearbyRequests() {
    _requestsSubscription?.cancel();
    _requestsSubscription = _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen(
          (snapshot) {
            _latestDocs = snapshot.docs;
            _processOpenRequests();
          },
          onError: (error) {
            debugPrint('MechanicController: Error listening to open requests: $error');
          },
        );
  }

  void _processOpenRequests() {
    List<Map<String, dynamic>> nearbyList = [];

    for (var doc in _latestDocs) {
      final data = doc.data();
      final driverLat = data['driverLat'];
      final driverLng = data['driverLng'];

      double? distance;
      if (isLocationLoaded.value && driverLat != null && driverLng != null) {
        try {
          final dLat = (driverLat as num).toDouble();
          final dLng = (driverLng as num).toDouble();
          distance = Geolocator.distanceBetween(
                mechanicLat.value,
                mechanicLng.value,
                dLat,
                dLng,
              ) /
              1000;
        } catch (_) {}
      }

      // If location is loaded and not devMode, filter to within 20 km.
      // If devMode is active or location is not yet loaded, keep visible.
      final isNearby = distance == null || distance <= 20 || DevConfig.devMode;

      if (isNearby) {
        nearbyList.add({
          ...data,
          'id': doc.id,
          'distance': distance?.toStringAsFixed(1),
        });
      }
    }

    // Sort: requests with valid distance closest first, then by createdAt newest first
    nearbyList.sort((a, b) {
      final distA = double.tryParse(a['distance']?.toString() ?? '');
      final distB = double.tryParse(b['distance']?.toString() ?? '');
      if (distA != null && distB != null) {
        return distA.compareTo(distB);
      }
      if (distA != null) return -1;
      if (distB != null) return 1;

      final aTs = a['createdAt'] as Timestamp?;
      final bTs = b['createdAt'] as Timestamp?;
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return -1;
      if (bTs == null) return 1;
      return bTs.compareTo(aTs);
    });

    openRequests.value = nearbyList;
  }

  // ✅ Accept a request with transparent locked travel fee validation
  Future<void> acceptRequest(
    String requestId, {
    TravelFeeBreakdown? lockedTravelFee,
  }) async {
    try {
      await MechanicService.acceptRequest(
        requestId,
        hasActiveJob.value,
        mechanicLat: isLocationLoaded.value ? mechanicLat.value : null,
        mechanicLng: isLocationLoaded.value ? mechanicLng.value : null,
        lockedTravelFee: lockedTravelFee,
      );

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

  /// Calculates or retrieves the transparent travel fee breakdown for a specific request.
  Future<TravelFeeBreakdown> calculateFeeForRequest(
    Map<String, dynamic> requestData,
  ) async {
    // If already locked in Firestore, return the locked breakdown
    if (requestData['lockedTravelFee'] is Map) {
      return TravelFeeBreakdown.fromMap(
        Map<String, dynamic>.from(requestData['lockedTravelFee'] as Map),
      );
    }

    final driverLat = (requestData['driverLat'] as num?)?.toDouble();
    final driverLng = (requestData['driverLng'] as num?)?.toDouble();

    final config = await PricingConfigService.fetchPricingConfig();

    if (driverLat == null || driverLng == null) {
      return PricingConfigService.calculateTravelFee(
        distanceKm: 0.0,
        config: config,
      );
    }

    final originLat = isLocationLoaded.value ? mechanicLat.value : driverLat;
    final originLng = isLocationLoaded.value ? mechanicLng.value : driverLng;

    final distResult = await DistanceCalculationService.calculateDrivingDistance(
      originLat: originLat,
      originLng: originLng,
      destLat: driverLat,
      destLng: driverLng,
    );

    return PricingConfigService.calculateTravelFee(
      distanceKm: distResult.distanceKm,
      config: config,
      isDrivingDistance: distResult.isDrivingDistance,
    );
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

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class MechanicController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Bottom navigation management
  var currentIndex = 0.obs;

  // Tab management (for Current Job / All Requests tabs)
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
    super.onClose();
  }

  // 📍 Initialize mechanic location and listeners
  Future<void> _initializeMechanic() async {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      mechanicLat.value = position.latitude;
      mechanicLng.value = position.longitude;
      isLocationLoaded.value = true;

      print("✅ Mechanic Location: ${mechanicLat.value}, ${mechanicLng.value}");
    } catch (e) {
      print("❌ Location Error: $e");
      Get.snackbar("Error", "Could not fetch location");
    }
  }

  // 🎧 Listen to mechanic's active job
  void _listenToActiveJob() {
    final uid = _auth.currentUser!.uid;

    _activeJobSubscription = _firestore
        .collection('requests')
        .where('mechanicId', isEqualTo: uid)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        hasActiveJob.value = true;
        activeJob.value = {
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        };
      } else {
        hasActiveJob.value = false;
        activeJob.value = null;
      }
    });
  }

  // 🎧 Listen to nearby open requests (Real-time)
  void _listenToNearbyRequests() {
    _requestsSubscription = _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((snapshot) {
      if (!isLocationLoaded.value) {
        openRequests.clear();
        return;
      }

      List<Map<String, dynamic>> nearbyList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final driverLat = data['driverLat'];
        final driverLng = data['driverLng'];

        if (driverLat == null || driverLng == null) continue;

        // Calculate distance
        double distance = Geolocator.distanceBetween(
          mechanicLat.value,
          mechanicLng.value,
          driverLat,
          driverLng,
        ) / 1000; // Convert to km

        // Only show requests within 20 km
        if (distance <= 20) {
          nearbyList.add({
            ...data,
            'id': doc.id,
            'distance': distance.toStringAsFixed(1),
          });
        }
      }

      // Sort by distance (closest first)
      nearbyList.sort((a, b) =>
          double.parse(a['distance']).compareTo(double.parse(b['distance']))
      );

      openRequests.value = nearbyList;
    });
  }

  // ✅ Accept a request
  Future<void> acceptRequest(String requestId) async {
    try {
      final uid = _auth.currentUser!.uid;
      final mechanicPhone = _auth.currentUser!.phoneNumber;

      await _firestore.collection('requests').doc(requestId).update({
        'status': 'accepted',
        'mechanicId': uid,
        'mechanicPhone': mechanicPhone,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Request accepted!");
      changeInnerTab(0); // Switch to "Current Job" tab
    } catch (e) {
      Get.snackbar("Error", "Failed to accept request: $e");
    }
  }

  // ❌ Cancel active job
  Future<void> cancelActiveJob() async {
    if (activeJob.value == null) return;

    try {
      await _firestore.collection('requests').doc(activeJob.value!['id']).update({
        'status': 'open',
        'mechanicId': FieldValue.delete(),
        'mechanicPhone': FieldValue.delete(),
        'acceptedAt': FieldValue.delete(),
      });

      Get.snackbar("Success", "Job cancelled");
    } catch (e) {
      Get.snackbar("Error", "Failed to cancel job: $e");
    }
  }

  // ✅ Complete job
  Future<void> completeJob() async {
    if (activeJob.value == null) return;

    try {
      await _firestore.collection('requests').doc(activeJob.value!['id']).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Job completed!");
    } catch (e) {
      Get.snackbar("Error", "Failed to complete job: $e");
    }
  }

  // Tab switching (Current Job / All Requests)
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
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/modules/driver/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class FindMechanicsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var isListView = true.obs;

  // Data
  var allMechanics = <Map<String, dynamic>>[].obs;

  // Location
  var driverLat = 0.0.obs;
  var driverLng = 0.0.obs;
  var locationName = 'Fetching...'.obs;

  // Filters & Search
  var searchQuery = ''.obs;
  var selectedService = 'All'.obs;
  var maxDistanceKm = 20.0.obs;
  var minimumRating = 0.0.obs;
  var hideOffline = false.obs;
  var sortBy = 'Distance'.obs; // "Distance", "Rating", "Jobs Done"

  StreamSubscription? _mechanicsSubscription;
  Worker? _searchDebounce;

  final List<String> availableServices = [
    'All',
    'Tire Services',
    'Engine Repair',
    'Battery Services',
    'Brake Services',
    'AC Repair',
    'Electrical',
    'Body Work',
    'Oil Change',
    'General Repair',
  ];

  @override
  void onInit() {
    super.onInit();
    _fetchDriverLocationAndMechanics();

    // Debounce search to avoid re-filtering on every keystroke
    _searchDebounce = debounce(
      searchQuery,
      (_) {}, // filteredMechanics is a computed getter, debounce triggers Obx
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _mechanicsSubscription?.cancel();
    _searchDebounce?.dispose();
    super.onClose();
  }

  void toggleView() {
    isListView.value = !isListView.value;
  }

  Future<void> refreshData() async {
    await _fetchDriverLocationAndMechanics();
  }

  Future<void> _fetchDriverLocationAndMechanics() async {
    isLoading.value = true;
    try {
      final locData = await LocationService.getLocationData();
      driverLat.value = locData['lat'];
      driverLng.value = locData['lng'];
      locationName.value = locData['locationName'] ?? 'Unknown Location';
    } catch (e) {
      locationName.value = "Location disabled";
    }

    _listenToMechanics();
  }

  void _listenToMechanics() {
    _mechanicsSubscription?.cancel();
    _mechanicsSubscription = _firestore
        .collection('users')
        .where('role', isEqualTo: 'mechanic')
        .where('verificationStatus', isEqualTo: 'approved')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            List<Map<String, dynamic>> mechanics = [];

            for (var doc in snapshot.docs) {
              final data = doc.data();
              final lat = data['latitude'];
              final lng = data['longitude'];
              double dist = 0.0;

              // Calculate distance
              if (lat != null && lng != null && driverLat.value != 0.0) {
                dist =
                    Geolocator.distanceBetween(
                      driverLat.value,
                      driverLng.value,
                      lat,
                      lng,
                    ) /
                    1000; // in km
              }

              mechanics.add({...data, 'id': doc.id, 'distance': dist});
            }

            allMechanics.value = mechanics;
            isLoading.value = false;
          },
          onError: (error) {
            isLoading.value = false;
          },
        );
  }

  List<Map<String, dynamic>> get filteredMechanics {
    // Explicitly read the observable to ensure Obx reacts properly
    final List<Map<String, dynamic>> sourceList = allMechanics.toList();

    var result = sourceList.where((mech) {
      final dist = mech['distance'] as double? ?? 999.0;
      if (dist > maxDistanceKm.value) return false;

      final rating = (mech['rating'] ?? 0.0).toDouble();
      if (rating < minimumRating.value) return false;

      if (hideOffline.value && mech['isOnline'] != true) return false;

      // Filter by verification
      if (mech['verificationStatus'] != 'approved') return false;

      // Filter by service
      if (selectedService.value != 'All') {
        final services = List<String>.from(mech['servicesOffered'] ?? []);
        final spec = List<String>.from(mech['specializations'] ?? []);
        bool hasService =
            services.any(
              (s) => s.toLowerCase() == selectedService.value.toLowerCase(),
            ) ||
            spec.any(
              (s) => s.toLowerCase() == selectedService.value.toLowerCase(),
            );

        if (!hasService) return false;
      }

      // Filter by search query
      if (searchQuery.value.isNotEmpty) {
        final q = searchQuery.value.toLowerCase();
        final name = (mech['fullName'] ?? mech['name'] ?? '')
            .toString()
            .toLowerCase();
        final shop = (mech['shopName'] ?? '').toString().toLowerCase();
        if (!name.contains(q) && !shop.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort
    result.sort((a, b) {
      if (sortBy.value == 'Rating') {
        final rA = (a['rating'] ?? 0.0).toDouble();
        final rB = (b['rating'] ?? 0.0).toDouble();
        return rB.compareTo(rA);
      } else if (sortBy.value == 'Jobs Done') {
        final jA = (a['jobsCompleted'] ?? 0).toInt();
        final jB = (b['jobsCompleted'] ?? 0).toInt();
        return jB.compareTo(jA);
      } else {
        // default Distance
        final dA = (a['distance'] ?? 999.0).toDouble();
        final dB = (b['distance'] ?? 999.0).toDouble();
        return dA.compareTo(dB);
      }
    });

    return result;
  }

  void applyFilters({
    double? maxDist,
    double? minRating,
    bool? offline,
    String? sort,
  }) {
    if (maxDist != null) maxDistanceKm.value = maxDist;
    if (minRating != null) minimumRating.value = minRating;
    if (offline != null) hideOffline.value = offline;
    if (sort != null) sortBy.value = sort;
  }

  void clearFilters() {
    maxDistanceKm.value = 20.0;
    minimumRating.value = 0.0;
    hideOffline.value = false;
    sortBy.value = 'Distance';
    selectedService.value = 'All';
    searchQuery.value = '';
  }
}

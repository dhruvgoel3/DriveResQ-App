import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class MechanicRequestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var nearbyRequests = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Position? mechanicPosition;

  static const double RADIUS_IN_KM = 15;

  @override
  void onInit() {
    super.onInit();
    initFlow();
  }

  Future<void> initFlow() async {
    try {
      await _getMechanicLocation();
      _listenToRequests();
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  // 📍 GET MECHANIC LOCATION (SAFE)
  Future<void> _getMechanicLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
    }

    mechanicPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // 🔥 LISTEN TO REQUESTS (REAL-TIME)
  void _listenToRequests() {
    _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((snapshot) {
      nearbyRequests.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['driverLat'] == null || data['driverLng'] == null) continue;

        final distanceInMeters = Geolocator.distanceBetween(
          mechanicPosition!.latitude,
          mechanicPosition!.longitude,
          data['driverLat'],
          data['driverLng'],
        );

        final distanceInKm = distanceInMeters / 1000;

        if (distanceInKm <= RADIUS_IN_KM) {
          nearbyRequests.add({
            ...data,
            'id': doc.id,
            'distance': distanceInKm.toStringAsFixed(1),
          });
        }
      }

      // 🔑 VERY IMPORTANT
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      errorMessage.value = error.toString();
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class MechanicRequestsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 🔄 UI STATES
  var isLoading = true.obs;

  // 🔥 DATA
  var nearbyRequests = <Map<String, dynamic>>[].obs;
  var activeRequest = Rxn<Map<String, dynamic>>();

  Position? mechanicPosition;

  static const double RADIUS_IN_KM = 15;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _getMechanicLocation();
    _listenToActiveRequest();
    _listenToNearbyRequests();
  }

  // 📍 LOCATION
  Future<void> _getMechanicLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    mechanicPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ✅ ACTIVE REQUEST (ACCEPTED)
  void _listenToActiveRequest() {
    _firestore
        .collection('requests')
        .where('mechanicId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        activeRequest.value = {
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        };
      } else {
        activeRequest.value = null;
      }
    });
  }

  // 📡 NEARBY OPEN REQUESTS
  void _listenToNearbyRequests() {
    _firestore
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((snapshot) {
      nearbyRequests.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['driverLat'] == null || data['driverLng'] == null) continue;

        final distance = Geolocator.distanceBetween(
          mechanicPosition!.latitude,
          mechanicPosition!.longitude,
          data['driverLat'],
          data['driverLng'],
        );

        if (distance / 1000 <= RADIUS_IN_KM) {
          nearbyRequests.add({
            ...data,
            'id': doc.id,
            'distance': (distance / 1000).toStringAsFixed(1),
          });
        }
      }

      isLoading.value = false;
    });
  }
}

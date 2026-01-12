import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTrackingController extends GetxController {
  final String requestId;

  LiveTrackingController(this.requestId);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GoogleMapController? mapController;

  var driverMarker = Rxn<Marker>();
  var mechanicMarker = Rxn<Marker>();

  StreamSubscription? requestSub;
  StreamSubscription? locationSub;

  @override
  void onInit() {
    super.onInit();
    _listenToRequest();
    _startSendingMyLocation();
  }

  // 🔥 LISTEN TO DRIVER & MECHANIC LOCATIONS
  void _listenToRequest() {
    requestSub = _firestore
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .listen((doc) {
      final data = doc.data();
      if (data == null) return;

      if (data['driverLat'] != null) {
        driverMarker.value = Marker(
          markerId: const MarkerId("driver"),
          position: LatLng(data['driverLat'], data['driverLng']),
          infoWindow: const InfoWindow(title: "Driver"),
        );
      }

      if (data['mechanicLat'] != null) {
        mechanicMarker.value = Marker(
          markerId: const MarkerId("mechanic"),
          position: LatLng(data['mechanicLat'], data['mechanicLng']),
          infoWindow: const InfoWindow(title: "Mechanic"),
        );
      }

      _updateCamera();
    });
  }

  // 📡 SEND MY LIVE LOCATION
  void _startSendingMyLocation() async {
    locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      _firestore.collection('requests').doc(requestId).update({
        'mechanicLat': pos.latitude,
        'mechanicLng': pos.longitude,
      });
    });
  }

  // 🎥 ADJUST CAMERA
  void _updateCamera() {
    if (mapController == null) return;
    if (driverMarker.value == null || mechanicMarker.value == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        driverMarker.value!.position.latitude <
            mechanicMarker.value!.position.latitude
            ? driverMarker.value!.position.latitude
            : mechanicMarker.value!.position.latitude,
        driverMarker.value!.position.longitude <
            mechanicMarker.value!.position.longitude
            ? driverMarker.value!.position.longitude
            : mechanicMarker.value!.position.longitude,
      ),
      northeast: LatLng(
        driverMarker.value!.position.latitude >
            mechanicMarker.value!.position.latitude
            ? driverMarker.value!.position.latitude
            : mechanicMarker.value!.position.latitude,
        driverMarker.value!.position.longitude >
            mechanicMarker.value!.position.longitude
            ? driverMarker.value!.position.longitude
            : mechanicMarker.value!.position.longitude,
      ),
    );

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  @override
  void onClose() {
    requestSub?.cancel();
    locationSub?.cancel();
    super.onClose();
  }
}

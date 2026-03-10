import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTrackingController extends GetxController {
  final String requestId;
  final String role; // 'driver' or 'mechanic'

  LiveTrackingController(this.requestId, this.role);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GoogleMapController? mapController;

  var driverMarker = Rxn<Marker>();
  var mechanicMarker = Rxn<Marker>();

  StreamSubscription? requestSub;
  StreamSubscription? locationSub;

  LatLng? driverLatLng;
  LatLng? mechanicLatLng;

  @override
  void onInit() {
    super.onInit();
    _listenToRequest();

    // 🔒 ONLY MECHANIC SENDS LIVE LOCATION
    if (role == 'mechanic') {
      _startSendingMyLocation();
    }
  }

  // 🔥 LISTEN TO FIRESTORE (READ-ONLY FOR DRIVER)
  void _listenToRequest() {
    requestSub = _firestore
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .listen((doc) {
          final data = doc.data();
          if (data == null) return;

          if (data['driverLat'] != null && data['driverLng'] != null) {
            driverLatLng = LatLng(data['driverLat'], data['driverLng']);
            driverMarker.value = Marker(
              markerId: MarkerId("driver"),
              position: driverLatLng!,
              infoWindow: InfoWindow(title: "Driver"),
            );
          }

          if (data['mechanicLat'] != null && data['mechanicLng'] != null) {
            mechanicLatLng = LatLng(data['mechanicLat'], data['mechanicLng']);
            mechanicMarker.value = Marker(
              markerId: MarkerId("mechanic"),
              position: mechanicLatLng!,
              infoWindow: InfoWindow(title: "Mechanic"),
            );
          }

          _updateCamera();
        });
  }

  // 📡 SEND MECHANIC LOCATION ONLY
  void _startSendingMyLocation() {
    locationSub =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
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

  // 🎥 CAMERA FIT
  void _updateCamera() {
    if (mapController == null ||
        driverLatLng == null ||
        mechanicLatLng == null) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        driverLatLng!.latitude < mechanicLatLng!.latitude
            ? driverLatLng!.latitude
            : mechanicLatLng!.latitude,
        driverLatLng!.longitude < mechanicLatLng!.longitude
            ? driverLatLng!.longitude
            : mechanicLatLng!.longitude,
      ),
      northeast: LatLng(
        driverLatLng!.latitude > mechanicLatLng!.latitude
            ? driverLatLng!.latitude
            : mechanicLatLng!.latitude,
        driverLatLng!.longitude > mechanicLatLng!.longitude
            ? driverLatLng!.longitude
            : mechanicLatLng!.longitude,
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  void onClose() {
    requestSub?.cancel();
    locationSub?.cancel();
    super.onClose();
  }
}

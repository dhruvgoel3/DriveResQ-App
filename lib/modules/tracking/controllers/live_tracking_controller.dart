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

  bool userInteracted = false; // 🔥 VERY IMPORTANT

  @override
  void onInit() {
    super.onInit();
    _listenToRequest();

    if (role == 'mechanic') {
      _startSendingMyLocation();
    }
  }

  // 🔥 LISTEN TO FIRESTORE
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
          markerId: const MarkerId("driver"),
          position: driverLatLng!,
          infoWindow: const InfoWindow(title: "Driver"),
        );
      }

      if (data['mechanicLat'] != null && data['mechanicLng'] != null) {
        mechanicLatLng = LatLng(data['mechanicLat'], data['mechanicLng']);
        mechanicMarker.value = Marker(
          markerId: const MarkerId("mechanic"),
          position: mechanicLatLng!,
          infoWindow: const InfoWindow(title: "Mechanic"),
        );

        // 🔥 FOLLOW MECHANIC (MAIN FIX)
        _moveCameraToMechanic();
      }
    });
  }

  // 📡 SEND MECHANIC LOCATION
  void _startSendingMyLocation() {
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

  // 🎯 CAMERA FOLLOW MECHANIC
  void _moveCameraToMechanic() {
    if (mapController == null ||
        mechanicLatLng == null ||
        userInteracted) return;

    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: mechanicLatLng!,
          zoom: 16, // 🔥 STREET LEVEL
        ),
      ),
    );
  }

  // 🔥 FORCE CAMERA AFTER MAP LOAD
  void forceInitialCamera() {
    if (mechanicLatLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: mechanicLatLng!,
            zoom: 16,
          ),
        ),
      );
    } else if (driverLatLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: driverLatLng!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void onClose() {
    requestSub?.cancel();
    locationSub?.cancel();
    super.onClose();
  }
}

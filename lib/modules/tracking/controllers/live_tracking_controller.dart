import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

class LiveTrackingController extends GetxController {
  final String requestId;
  final String role; // 'driver' or 'mechanic'

  LiveTrackingController(this.requestId, this.role);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GoogleMapController? mapController;

  var markers = <Marker>{}.obs;
  var polylines = <Polyline>{}.obs;

  var isLoading = true.obs;
  var status = "accepted".obs;
  var mechanicPhone = "".obs;
  var distanceLabel = "Calculating...".obs;
  var etaLabel = "...".obs;

  LatLng? driverLatLng;
  LatLng? mechanicLatLng;

  StreamSubscription? requestSub;
  StreamSubscription? mechanicLocationSub;
  StreamSubscription? myLocationSub;

  @override
  void onInit() {
    super.onInit();
    _initializeTracking();
  }

  @override
  void onClose() {
    requestSub?.cancel();
    mechanicLocationSub?.cancel();
    myLocationSub?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  Future<void> _initializeTracking() async {
    if (role == 'driver') {
      await _getDriverLocation();
      _listenToRequestUpdates();
    } else if (role == 'mechanic') {
      await _getMechanicLocation();
      _listenToRequestUpdates();
      _startSendingMyLocation();
    }
  }

  // Driver explicitly gets standard location if not pushed frequently
  Future<void> _getDriverLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      driverLatLng = LatLng(position.latitude, position.longitude);
      _updateDriverMarker();
      isLoading.value = false;
    } catch (e) {
      AppSnackbar.error('Could not get your location');
    }
  }

  Future<void> _getMechanicLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      mechanicLatLng = LatLng(position.latitude, position.longitude);
      _updateMechanicMarker();
      isLoading.value = false;
    } catch (e) {
      AppSnackbar.error('Could not get your location');
    }
  }

  void _listenToRequestUpdates() {
    requestSub = _firestore
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final mechanicId = data['mechanicId'];
      status.value = data['status'] ?? 'accepted';
      mechanicPhone.value = data['mechanicPhone'] ?? '';

      if (status.value == 'completed' || status.value == 'cancelled') {
        Get.back();
        AppSnackbar.info(
          'This request has been ${status.value}',
          title: 'Request ${status.value.capitalize}',
        );
        return;
      }

      if (role == 'driver' && mechanicId != null) {
        _listenToMechanicLocation(mechanicId);
      } else if (role == 'mechanic') {
        if (data['driverLat'] != null && data['driverLng'] != null) {
          driverLatLng = LatLng(data['driverLat'], data['driverLng']);
          _updateDriverMarker();
          
          _updateRoute();
          _calculateDistanceAndETA();
          if (mapController != null) _moveCameraToShowBoth();
        }
      }
    });
  }

  void _listenToMechanicLocation(String mechanicId) {
    mechanicLocationSub?.cancel();
    mechanicLocationSub = _firestore
        .collection('mechanic_locations')
        .doc(mechanicId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final lat = data['latitude'];
      final lng = data['longitude'];

      if (lat != null && lng != null) {
        mechanicLatLng = LatLng(lat, lng);
        _updateMechanicMarker();
        _updateRoute();
        _calculateDistanceAndETA();
        if (mapController != null) _moveCameraToShowBoth();
      }
    });
  }

  void _startSendingMyLocation() {
    myLocationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      mechanicLatLng = LatLng(pos.latitude, pos.longitude);
      _firestore.collection('mechanic_locations').doc(FirebaseAuth.instance.currentUser?.uid).set({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _updateMechanicMarker();
      _updateRoute();
      _calculateDistanceAndETA();
    });
  }

  void _updateDriverMarker() {
    if (driverLatLng == null) return;
    markers.removeWhere((m) => m.markerId.value == 'driver');
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Driver Location'),
      ),
    );
  }

  void _updateMechanicMarker() {
    if (mechanicLatLng == null) return;
    markers.removeWhere((m) => m.markerId.value == 'mechanic');
    markers.add(
      Marker(
        markerId: const MarkerId('mechanic'),
        position: mechanicLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Mechanic Location'),
      ),
    );
  }

  void _updateRoute() {
    if (driverLatLng == null || mechanicLatLng == null) return;
    polylines.clear();
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [driverLatLng!, mechanicLatLng!],
        color: const Color(0xFF6C63FF),
        width: 4,
      ),
    );
  }

  void _calculateDistanceAndETA() {
    if (driverLatLng == null || mechanicLatLng == null) return;

    double distanceInMeters = Geolocator.distanceBetween(
      mechanicLatLng!.latitude, mechanicLatLng!.longitude,
      driverLatLng!.latitude, driverLatLng!.longitude,
    );

    double distanceInKm = distanceInMeters / 1000;
    double timeInHours = distanceInKm / 40;
    int timeInMinutes = (timeInHours * 60).round();

    distanceLabel.value = distanceInKm < 1
        ? "${distanceInMeters.toStringAsFixed(0)} m"
        : "${distanceInKm.toStringAsFixed(1)} km";
    etaLabel.value = timeInMinutes < 1 ? "< 1 min" : "$timeInMinutes min";
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (driverLatLng != null && mechanicLatLng != null) {
      _moveCameraToShowBoth();
    }
  }

  void moveCameraToShowBoth() => _moveCameraToShowBoth();

  void _moveCameraToShowBoth() {
    if (mapController == null || driverLatLng == null || mechanicLatLng == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        driverLatLng!.latitude < mechanicLatLng!.latitude ? driverLatLng!.latitude : mechanicLatLng!.latitude,
        driverLatLng!.longitude < mechanicLatLng!.longitude ? driverLatLng!.longitude : mechanicLatLng!.longitude,
      ),
      northeast: LatLng(
        driverLatLng!.latitude > mechanicLatLng!.latitude ? driverLatLng!.latitude : mechanicLatLng!.latitude,
        driverLatLng!.longitude > mechanicLatLng!.longitude ? driverLatLng!.longitude : mechanicLatLng!.longitude,
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void callMechanic() async {
    if (mechanicPhone.value.isEmpty) {
      AppSnackbar.error('Phone number not available');
      return;
    }
    final uri = Uri.parse('tel:${mechanicPhone.value}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppSnackbar.error('Cannot make call');
    }
  }

  void openNavigation() async {
    if (mechanicLatLng == null && role == 'driver') {
      AppSnackbar.error('Location not available');
      return;
    }
    if (driverLatLng == null && role == 'mechanic') {
      AppSnackbar.error('Location not available');
      return;
    }
    
    final target = role == 'driver' ? mechanicLatLng : driverLatLng;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${target!.latitude},${target.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppSnackbar.error('Cannot open maps');
    }
  }
}

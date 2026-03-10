import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class MechanicLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static StreamSubscription<Position>? _positionStream;
  static bool _isTracking = false;

  /// Start tracking mechanic's location and updating to Firestore
  static Future<void> startTracking() async {
    if (_isTracking) {
      debugPrint("Already tracking location");
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint("No user logged in");
      return;
    }

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        debugPrint("Location permission denied");
        return;
      }

      // Start listening to location updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) {
            _updateLocationToFirestore(uid, position);
          });

      _isTracking = true;
      debugPrint("Started tracking mechanic location");
    } catch (e) {
      debugPrint("Error starting location tracking: $e");
    }
  }

  /// Update location to Firestore
  static Future<void> _updateLocationToFirestore(
    String uid,
    Position position,
  ) async {
    try {
      await _firestore.collection('mechanic_locations').doc(uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'accuracy': position.accuracy,
      });

      debugPrint(
        "Location updated: ${position.latitude}, ${position.longitude}",
      );
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  /// Stop tracking location
  static void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    debugPrint("Stopped tracking location");
  }

  /// Check if currently tracking
  static bool get isTracking => _isTracking;
}

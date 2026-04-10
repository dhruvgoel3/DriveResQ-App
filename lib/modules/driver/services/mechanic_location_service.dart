import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

/// A background service responsible for tracking and broadcasting the
/// mechanic's live coordinates to Firestore during an active job.
class MechanicLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static StreamSubscription<Position>? _positionSubscription;
  static bool _isTrackingActive = false;

  /// Starts high-accuracy location tracking for the currently logged-in mechanic.
  ///
  /// Updates are pushed to the 'mechanic_locations' collection whenever the
  /// mechanic moves by at least 10 meters.
  static Future<void> startTracking() async {
    if (_isTrackingActive) {
      /* print stripped */
      return;
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // 1. Permission verification
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        /* print stripped */
        return;
      }

      // 2. Configure tracking parameters
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update threshold in meters
      );

      // 3. Start listener
      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen((
            Position position,
          ) {
            _syncPositionToCloud(currentUser.uid, position);
          });

      _isTrackingActive = true;
      /* print stripped */
    } catch (e) {
      /* print stripped */
    }
  }

  /// Syncs the current [position] to the mechanic's location document in Firestore.
  static Future<void> _syncPositionToCloud(
    String uid,
    Position position,
  ) async {
    try {
      await _firestore.collection('mechanic_locations').doc(uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'accuracy': position.accuracy,
        'heading': position.heading,
        'speed': position.speed,
      });
    } catch (e) {
      /* print stripped */
    }
  }

  /// Ceases all background location tracking and releases resources.
  static void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTrackingActive = false;
    /* print stripped */
  }

  /// Indicates whether the tracking service is currently running.
  static bool get isTracking => _isTrackingActive;
}

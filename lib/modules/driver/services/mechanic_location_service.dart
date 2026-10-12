import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// A service responsible for tracking and broadcasting the
/// mechanic's live coordinates to Firestore during an active job.
class MechanicLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static StreamSubscription<Position>? _positionSubscription;
  static bool _isTrackingActive = false;

  /// Starts high-accuracy location tracking for the currently logged-in mechanic.
  ///
  /// Immediately fetches current position, then streams ongoing updates
  /// whenever the mechanic moves by at least 10 meters.
  static Future<void> startTracking() async {
    if (_isTrackingActive) return;

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
        debugPrint('MechanicLocationService: Location permission not granted');
        return;
      }

      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        debugPrint('MechanicLocationService: Device location service is disabled');
        return;
      }

      // 2. Broadcast immediate position so driver sees coordinates without waiting for movement
      try {
        final currentPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 6),
          ),
        );
        await _syncPositionToCloud(currentUser.uid, currentPos);
      } catch (e) {
        debugPrint('MechanicLocationService initial fix failed, checking last known: $e');
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          await _syncPositionToCloud(currentUser.uid, lastKnown);
        }
      }

      // 3. Configure continuous tracking parameters
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update threshold in meters
      );

      // 4. Start listener
      _positionSubscription?.cancel();
      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen(
        (Position position) {
          _syncPositionToCloud(currentUser.uid, position);
        },
        onError: (Object err) {
          debugPrint('MechanicLocationService positionStream error: $err');
        },
      );

      _isTrackingActive = true;
      debugPrint('MechanicLocationService: tracking started successfully');
    } catch (e) {
      debugPrint('MechanicLocationService.startTracking failed: $e');
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
        'updatedAt': FieldValue.serverTimestamp(),
        'accuracy': position.accuracy,
        'heading': position.heading,
        'speed': position.speed,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('MechanicLocationService._syncPositionToCloud failed: $e');
    }
  }

  /// Ceases all background location tracking and releases resources.
  static void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTrackingActive = false;
    debugPrint('MechanicLocationService: tracking stopped');
  }

  /// Indicates whether the tracking service is currently running.
  static bool get isTracking => _isTrackingActive;
}

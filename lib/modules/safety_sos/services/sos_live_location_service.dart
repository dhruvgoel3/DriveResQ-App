import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Service responsible for real-time live location broadcasting during an SOS emergency.
///
/// Continuously streams high-accuracy GPS coordinates to Firestore (`sos_incidents/{incidentId}`)
/// so emergency contacts can monitor the driver's live movement in real-time.
class SosLiveLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String baseTrackingUrl = 'https://driveresq-app.web.app/sos-track.html';

  static StreamSubscription<Position>? _positionSub;
  static String? _activeIncidentId;

  /// Observable for current live position within the app UI
  static final Rxn<Position> currentLivePosition = Rxn<Position>();
  static final RxBool isStreamingActive = false.obs;
  static final RxInt updateCount = 0.obs;

  /// Builds the web-accessible real-time live tracking URL.
  static String buildLiveTrackingUrl(String incidentId) {
    return '$baseTrackingUrl?id=$incidentId';
  }

  /// Builds Google Maps direct navigation URL.
  static String buildGoogleMapsNavUrl(double lat, double lng) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
  }

  /// Starts continuous real-time GPS broadcasting for [incidentId].
  static Future<void> startLiveTracking(
    String incidentId, {
    Position? initialPosition,
  }) async {
    // If already tracking another incident, cancel previous
    if (_positionSub != null && _activeIncidentId != incidentId) {
      await stopLiveTracking(_activeIncidentId ?? '');
    }

    _activeIncidentId = incidentId;
    isStreamingActive.value = true;
    updateCount.value = 0;

    // 1. Immediately record initial position if available
    if (initialPosition != null) {
      currentLivePosition.value = initialPosition;
      await _broadcastLocation(incidentId, initialPosition);
    }

    // 2. Start high-frequency GPS stream (every 5 meters or location change)
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update when driver moves 5 meters
      );

      _positionSub = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (position) async {
          currentLivePosition.value = position;
          updateCount.value++;
          await _broadcastLocation(incidentId, position);
        },
        onError: (error) {
          debugPrint('SosLiveLocationService: Stream error: $error');
        },
        cancelOnError: false,
      );

      debugPrint('SosLiveLocationService: Started live GPS broadcast for $incidentId');
    } catch (e) {
      debugPrint('SosLiveLocationService: Failed to start position stream: $e');
    }
  }

  /// Broadcasts a single location update to Firestore document.
  static Future<void> _broadcastLocation(String incidentId, Position position) async {
    try {
      final docRef = _firestore.collection('sos_incidents').doc(incidentId);

      final updateData = <String, dynamic>{
        'liveLatitude': position.latitude,
        'liveLongitude': position.longitude,
        'liveAccuracy': position.accuracy,
        'liveSpeed': position.speed,
        'liveHeading': position.heading,
        'isLiveTrackingActive': true,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'locationTrail': FieldValue.arrayUnion([
          {
            'lat': position.latitude,
            'lng': position.longitude,
            'speed': position.speed,
            't': Timestamp.now(),
          }
        ]),
      };

      await docRef.set(updateData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('SosLiveLocationService: Broadcast error for $incidentId: $e');
    }
  }

  /// Stops continuous real-time GPS broadcasting.
  static Future<void> stopLiveTracking(String incidentId) async {
    try {
      await _positionSub?.cancel();
      _positionSub = null;
      isStreamingActive.value = false;
      _activeIncidentId = null;

      if (incidentId.isNotEmpty) {
        await _firestore.collection('sos_incidents').doc(incidentId).set(
          {
            'isLiveTrackingActive': false,
            'status': 'resolved',
            'resolvedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      debugPrint('SosLiveLocationService: Stopped live GPS broadcast for $incidentId');
    } catch (e) {
      debugPrint('SosLiveLocationService: Error stopping live tracking: $e');
    }
  }
}

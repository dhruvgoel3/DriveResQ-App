import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// A high-level service for managing device location and reverse geocoding.
/// 
/// This service provides streamlined methods to fetch precise coordinates
/// and convert them into human-readable addresses for display on maps and cards.
class LocationService {
  
  /// Fetches the current device location with both coordinates and a readable name.
  /// 
  /// Throws an [Exception] if location services are disabled or permissions are denied.
  static Future<Map<String, dynamic>> getLocationData() async {
    try {
      // 1. Permission and service checks
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are currently disabled on your device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions were denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable them in settings.');
      }

      // 2. Fetch precise position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Convert to human-readable address
      final locationName = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return {
        'locationName': locationName,
        'lat': position.latitude,
        'lng': position.longitude,
      };
    } catch (e) {
      debugPrint("LocationService Critical Error: $e");
      rethrow;
    }
  }

  /// Performs reverse geocoding to turn [lat] and [lng] into a formatted address string.
  /// 
  /// If geocoding fails, returns "Current Location" as a safe fallback.
  static Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];

        // Intelligently build the address based on available fields
        if (place.street != null && place.street!.isNotEmpty && place.street != place.locality) {
          parts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          parts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          parts.add(place.administrativeArea!);
        }

        return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
      }

      return 'Current Location';
    } catch (e) {
      debugPrint("Reverse Geocoding Failed: $e");
      return 'Current Location';
    }
  }

  /// Simple utility to fetch the raw [Position] without geocoding metadata.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Permission denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

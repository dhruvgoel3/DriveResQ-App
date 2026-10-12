import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Result of driving distance calculation between mechanic and driver.
class DrivingDistanceResult {
  final double distanceKm;
  final String distanceText;
  final int? durationSeconds;
  final String? durationText;
  final bool isDrivingDistance; // true = Google Distance Matrix API, false = Geodesic fallback

  const DrivingDistanceResult({
    required this.distanceKm,
    required this.distanceText,
    this.durationSeconds,
    this.durationText,
    required this.isDrivingDistance,
  });
}

/// Service to calculate accurate driving distance between driver and mechanic
/// using the Google Maps Distance Matrix API with resilient local geodesic fallback.
class DistanceCalculationService {
  // Configured Google Maps API Key from project settings
  static const String defaultApiKey = 'AIzaSyBHXjEt53uJh7ukbhXgVx7OxYmqQsIoR5Y';

  // Cache to prevent repetitive API calls for the same coordinates
  static final Map<String, DrivingDistanceResult> _cache = {};

  /// Calculates the driving distance between the mechanic and the stranded driver.
  ///
  /// Uses Google Maps Distance Matrix API (`mode=driving`) for real road network routing.
  /// If the API is offline or returns an error, falls back safely to Geolocator geodesic distance.
  static Future<DrivingDistanceResult> calculateDrivingDistance({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? apiKey,
  }) async {
    final cacheKey =
        '${originLat.toStringAsFixed(3)},${originLng.toStringAsFixed(3)}->${destLat.toStringAsFixed(3)},${destLng.toStringAsFixed(3)}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final key = apiKey ?? defaultApiKey;

    // 1. Attempt Google Maps Distance Matrix API
    if (key.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=$originLat,$originLng'
          '&destinations=$destLat,$destLng'
          '&mode=driving'
          '&key=$key',
        );

        final response = await http.get(url).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final status = data['status'] as String?;

          if (status == 'OK') {
            final rows = data['rows'] as List<dynamic>?;
            if (rows != null && rows.isNotEmpty) {
              final elements = rows.first['elements'] as List<dynamic>?;
              if (elements != null && elements.isNotEmpty) {
                final element = elements.first as Map<String, dynamic>;
                final elemStatus = element['status'] as String?;

                if (elemStatus == 'OK') {
                  final distanceObj = element['distance'] as Map<String, dynamic>?;
                  final durationObj = element['duration'] as Map<String, dynamic>?;

                  final meters = (distanceObj?['value'] as num?)?.toDouble() ?? 0.0;
                  final distanceKm = double.parse((meters / 1000.0).toStringAsFixed(2));
                  final distText = distanceObj?['text']?.toString() ?? '${distanceKm.toStringAsFixed(1)} km';
                  final durSeconds = (durationObj?['value'] as num?)?.toInt();
                  final durText = durationObj?['text']?.toString();

                  final result = DrivingDistanceResult(
                    distanceKm: distanceKm,
                    distanceText: distText,
                    durationSeconds: durSeconds,
                    durationText: durText,
                    isDrivingDistance: true,
                  );

                  _cache[cacheKey] = result;
                  return result;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('DistanceCalculationService: Google Distance Matrix failed ($e), using fallback.');
      }
    }

    // 2. Fallback: Geolocator geodesic distance
    return _calculateGeodesicFallback(originLat, originLng, destLat, destLng, cacheKey);
  }

  static DrivingDistanceResult _calculateGeodesicFallback(
    double originLat,
    double originLng,
    double destLat,
    double destLng,
    String cacheKey,
  ) {
    try {
      final meters = Geolocator.distanceBetween(originLat, originLng, destLat, destLng);
      // Real road network routing is roughly 1.25x straight-line distance in urban grids
      final estimatedRoadKm = double.parse(((meters * 1.25) / 1000.0).toStringAsFixed(2));
      final result = DrivingDistanceResult(
        distanceKm: estimatedRoadKm,
        distanceText: '${estimatedRoadKm.toStringAsFixed(1)} km (est)',
        isDrivingDistance: false,
      );
      _cache[cacheKey] = result;
      return result;
    } catch (e) {
      debugPrint('DistanceCalculationService: Geodesic fallback failed: $e');
      return const DrivingDistanceResult(
        distanceKm: 1.0,
        distanceText: '1.0 km (est)',
        isDrivingDistance: false,
      );
    }
  }

  /// Clears in-memory route cache if needed.
  static void clearCache() {
    _cache.clear();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/travel_pricing_model.dart';

/// Service responsible for fetching dynamic travel pricing configurations from Firestore
/// and calculating travel fee breakdowns using the transparent business formula.
class PricingConfigService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'pricing_config';
  static const String docName = 'travel_pricing';

  static TravelPricingConfig _cachedConfig = TravelPricingConfig.defaultConfig();
  static bool _hasLoadedOnce = false;

  /// Get current cached config synchronously (or default).
  static TravelPricingConfig get currentConfig => _cachedConfig;
  static bool get hasLoadedOnce => _hasLoadedOnce;

  /// Stream dynamic pricing config from Firestore.
  /// If document does not exist yet, initializes with defaults.
  static Stream<TravelPricingConfig> watchPricingConfig() {
    return _firestore
        .collection(collectionName)
        .doc(docName)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _cachedConfig = TravelPricingConfig.fromMap(snapshot.data()!);
        _hasLoadedOnce = true;
        return _cachedConfig;
      }
      return _cachedConfig;
    }).handleError((error) {
      debugPrint('PricingConfigService: Stream error, using cached defaults: $error');
      return _cachedConfig;
    });
  }

  /// Fetch pricing configuration once from Firestore.
  static Future<TravelPricingConfig> fetchPricingConfig() async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docName).get();
      if (doc.exists && doc.data() != null) {
        _cachedConfig = TravelPricingConfig.fromMap(doc.data()!);
        _hasLoadedOnce = true;
        return _cachedConfig;
      } else {
        // Document doesn't exist yet: initialize with the standard formula defaults
        final initialConfig = TravelPricingConfig.defaultConfig();
        try {
          await _firestore.collection(collectionName).doc(docName).set(
                initialConfig.toMap(),
                SetOptions(merge: true),
              );
        } catch (_) {
          // May not have admin write permissions, which is fine
        }
        _cachedConfig = initialConfig;
        _hasLoadedOnce = true;
        return _cachedConfig;
      }
    } catch (e) {
      debugPrint('PricingConfigService.fetchPricingConfig error: $e');
      return _cachedConfig;
    }
  }

  /// Price Calculation Engine:
  /// Takes [distanceKm] and computes the transparent itemized fee.
  ///
  /// Formula:
  ///   - Base Dispatch Fee: ₹50.00
  ///   - Fuel: ₹2.30 / km (₹103.32 / 45 km)
  ///   - Wear & Tear: ₹1.50 / km
  ///   - Time & Labor: ₹8.20 / km
  ///   - Total Per-KM Rate: ₹20.00 / km
  ///   - Distance Charge = distanceKm * perKmRate
  ///   - Total Fee = baseDispatchFee + distanceCharge
  static TravelFeeBreakdown calculateTravelFee({
    required double distanceKm,
    TravelPricingConfig? config,
    bool isDrivingDistance = true,
  }) {
    final effectiveConfig = config ?? _cachedConfig;

    final sanitizedDistance = distanceKm < 0.0 ? 0.0 : distanceKm;
    final distanceCharge = sanitizedDistance * effectiveConfig.perKmRate;
    final totalFee = effectiveConfig.baseDispatchFee + distanceCharge;

    final fuelCost = sanitizedDistance * effectiveConfig.fuelCostPerKm;
    final wearTearCost = sanitizedDistance * effectiveConfig.wearTearCostPerKm;
    final timeLaborCost = sanitizedDistance * effectiveConfig.timeLaborCompensationPerKm;

    return TravelFeeBreakdown(
      distanceKm: sanitizedDistance,
      baseDispatchFee: effectiveConfig.baseDispatchFee,
      perKmRate: effectiveConfig.perKmRate,
      distanceCharge: distanceCharge,
      totalFee: totalFee,
      fuelCost: fuelCost,
      wearTearCost: wearTearCost,
      timeLaborCost: timeLaborCost,
      isDrivingDistance: isDrivingDistance,
    );
  }
}

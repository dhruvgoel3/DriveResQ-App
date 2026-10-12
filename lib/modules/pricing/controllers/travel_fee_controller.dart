import 'dart:async';
import 'package:get/get.dart';
import '../models/travel_pricing_model.dart';
import '../services/distance_calculation_service.dart';
import '../services/pricing_config_service.dart';

/// GetX controller managing travel fee calculations across mechanic and driver dashboards.
class TravelFeeController extends GetxController {
  final pricingConfig = TravelPricingConfig.defaultConfig().obs;
  final isLoadingConfig = false.obs;

  // Cache of calculated/locked fees by request ID
  final calculatedFees = <String, TravelFeeBreakdown>{}.obs;
  final isCalculating = <String, bool>{}.obs;

  StreamSubscription<TravelPricingConfig>? _configSub;

  @override
  void onInit() {
    super.onInit();
    _initPricing();
  }

  @override
  void onClose() {
    _configSub?.cancel();
    super.onClose();
  }

  void _initPricing() {
    isLoadingConfig.value = true;
    _configSub = PricingConfigService.watchPricingConfig().listen((config) {
      pricingConfig.value = config;
      isLoadingConfig.value = false;
    });

    PricingConfigService.fetchPricingConfig().then((config) {
      pricingConfig.value = config;
      isLoadingConfig.value = false;
    });
  }

  /// Retrieves an existing locked travel fee or computes fresh driving distance & fee.
  Future<TravelFeeBreakdown> getOrCalculateFee({
    required String requestId,
    required double driverLat,
    required double driverLng,
    required double mechanicLat,
    required double mechanicLng,
    Map<String, dynamic>? existingLockedFee,
  }) async {
    // 1. If already locked in Firestore request document, use the locked fee directly
    if (existingLockedFee != null && existingLockedFee.isNotEmpty) {
      final locked = TravelFeeBreakdown.fromMap(existingLockedFee);
      calculatedFees[requestId] = locked;
      return locked;
    }

    // 2. Check local in-memory cache
    if (calculatedFees.containsKey(requestId)) {
      return calculatedFees[requestId]!;
    }

    // 3. Compute driving distance via Google Maps Distance Matrix API
    isCalculating[requestId] = true;
    try {
      final distResult = await DistanceCalculationService.calculateDrivingDistance(
        originLat: mechanicLat,
        originLng: mechanicLng,
        destLat: driverLat,
        destLng: driverLng,
      );

      final breakdown = PricingConfigService.calculateTravelFee(
        distanceKm: distResult.distanceKm,
        config: pricingConfig.value,
        isDrivingDistance: distResult.isDrivingDistance,
      );

      calculatedFees[requestId] = breakdown;
      return breakdown;
    } finally {
      isCalculating[requestId] = false;
    }
  }
}

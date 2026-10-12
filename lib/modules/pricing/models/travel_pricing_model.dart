import 'package:cloud_firestore/cloud_firestore.dart';

/// Configuration for travel fee calculation.
/// Fetched from Firestore collection `pricing_config`, doc `travel_pricing`.
class TravelPricingConfig {
  final double perKmRate;
  final double baseDispatchFee;
  final double fuelCostPerKm;
  final double wearTearCostPerKm;
  final double timeLaborCompensationPerKm;
  final DateTime? updatedAt;

  // Business formula defaults:
  // Fuel: ₹103.32 / 45km = ₹2.30/km
  // Maintenance: ₹1.50/km
  // Time & Labor: ₹8.20/km
  // Total Per-KM Rate: ₹20.00/km
  // Base Dispatch Fee: ₹50.00
  static const double defaultPerKmRate = 20.0;
  static const double defaultBaseDispatchFee = 50.0;
  static const double defaultFuelCostPerKm = 2.30;
  static const double defaultWearTearCostPerKm = 1.50;
  static const double defaultTimeLaborCompensationPerKm = 8.20;

  const TravelPricingConfig({
    this.perKmRate = defaultPerKmRate,
    this.baseDispatchFee = defaultBaseDispatchFee,
    this.fuelCostPerKm = defaultFuelCostPerKm,
    this.wearTearCostPerKm = defaultWearTearCostPerKm,
    this.timeLaborCompensationPerKm = defaultTimeLaborCompensationPerKm,
    this.updatedAt,
  });

  factory TravelPricingConfig.defaultConfig() {
    return TravelPricingConfig(
      perKmRate: defaultPerKmRate,
      baseDispatchFee: defaultBaseDispatchFee,
      fuelCostPerKm: defaultFuelCostPerKm,
      wearTearCostPerKm: defaultWearTearCostPerKm,
      timeLaborCompensationPerKm: defaultTimeLaborCompensationPerKm,
      updatedAt: DateTime.now(),
    );
  }

  factory TravelPricingConfig.fromMap(Map<String, dynamic> map) {
    return TravelPricingConfig(
      perKmRate: (map['per_km_rate'] ?? map['perKmRate'] ?? defaultPerKmRate as num).toDouble(),
      baseDispatchFee:
          (map['base_dispatch_fee'] ?? map['baseDispatchFee'] ?? defaultBaseDispatchFee as num).toDouble(),
      fuelCostPerKm:
          (map['fuel_cost_per_km'] ?? map['fuelCostPerKm'] ?? defaultFuelCostPerKm as num).toDouble(),
      wearTearCostPerKm:
          (map['wear_tear_cost_per_km'] ?? map['wearTearCostPerKm'] ?? defaultWearTearCostPerKm as num).toDouble(),
      timeLaborCompensationPerKm: (map['time_labor_compensation_per_km'] ??
              map['timeLaborCompensationPerKm'] ??
              defaultTimeLaborCompensationPerKm as num)
          .toDouble(),
      updatedAt: _parseTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'per_km_rate': perKmRate,
      'base_dispatch_fee': baseDispatchFee,
      'fuel_cost_per_km': fuelCostPerKm,
      'wear_tear_cost_per_km': wearTearCostPerKm,
      'time_labor_compensation_per_km': timeLaborCompensationPerKm,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

/// Detailed itemized breakdown of the travel fee for a given journey.
class TravelFeeBreakdown {
  final double distanceKm;
  final double baseDispatchFee;
  final double perKmRate;
  final double distanceCharge;
  final double totalFee;
  final double fuelCost;
  final double wearTearCost;
  final double timeLaborCost;
  final bool isDrivingDistance; // true = Google Distance Matrix API, false = geodesic fallback
  final DateTime? calculatedAt;

  const TravelFeeBreakdown({
    required this.distanceKm,
    required this.baseDispatchFee,
    required this.perKmRate,
    required this.distanceCharge,
    required this.totalFee,
    required this.fuelCost,
    required this.wearTearCost,
    required this.timeLaborCost,
    this.isDrivingDistance = true,
    this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'distanceKm': distanceKm,
      'baseDispatchFee': baseDispatchFee,
      'perKmRate': perKmRate,
      'distanceCharge': distanceCharge,
      'totalFee': totalFee,
      'fuelCost': fuelCost,
      'wearTearCost': wearTearCost,
      'timeLaborCost': timeLaborCost,
      'isDrivingDistance': isDrivingDistance,
      if (calculatedAt != null) 'calculatedAt': Timestamp.fromDate(calculatedAt!),
    };
  }

  factory TravelFeeBreakdown.fromMap(Map<String, dynamic> map) {
    return TravelFeeBreakdown(
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      baseDispatchFee: (map['baseDispatchFee'] as num?)?.toDouble() ?? 50.0,
      perKmRate: (map['perKmRate'] as num?)?.toDouble() ?? 20.0,
      distanceCharge: (map['distanceCharge'] as num?)?.toDouble() ?? 0.0,
      totalFee: (map['totalFee'] as num?)?.toDouble() ?? 50.0,
      fuelCost: (map['fuelCost'] as num?)?.toDouble() ?? 0.0,
      wearTearCost: (map['wearTearCost'] as num?)?.toDouble() ?? 0.0,
      timeLaborCost: (map['timeLaborCost'] as num?)?.toDouble() ?? 0.0,
      isDrivingDistance: map['isDrivingDistance'] as bool? ?? true,
      calculatedAt: TravelPricingConfig._parseTimestamp(map['calculatedAt']),
    );
  }
}

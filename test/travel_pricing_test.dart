import 'package:flutter_test/flutter_test.dart';
import 'package:driveresq_app/modules/pricing/models/travel_pricing_model.dart';
import 'package:driveresq_app/modules/pricing/services/pricing_config_service.dart';

void main() {
  group('Transparent Mechanic Travel Fee Calculation Engine', () {
    test('Default pricing configuration matches specified formula constants', () {
      final config = TravelPricingConfig.defaultConfig();

      expect(config.perKmRate, equals(20.00));
      expect(config.baseDispatchFee, equals(50.00));
      expect(config.fuelCostPerKm, equals(2.30));
      expect(config.wearTearCostPerKm, equals(1.50));
      expect(config.timeLaborCompensationPerKm, equals(8.20));

      // Verify itemized components sum up to perKmRate (or within rounding margin)
      final sumItemized = config.fuelCostPerKm +
          config.wearTearCostPerKm +
          config.timeLaborCompensationPerKm;
      expect(sumItemized, closeTo(12.00, 0.01));
    });

    test('Computes exact travel fee for 10 km journey with default rates', () {
      final config = TravelPricingConfig.defaultConfig();
      const distance = 10.0;

      final breakdown = PricingConfigService.calculateTravelFee(
        distanceKm: distance,
        config: config,
        isDrivingDistance: true,
      );

      // Distance charge: 10 km * ₹20.00/km = ₹200.00
      expect(breakdown.distanceCharge, equals(200.00));
      // Base fee: ₹50.00
      expect(breakdown.baseDispatchFee, equals(50.00));
      // Total fee: ₹50.00 + ₹200.00 = ₹250.00
      expect(breakdown.totalFee, equals(250.00));

      // Transparent component breakdowns
      expect(breakdown.fuelCost, equals(23.00)); // 10 * 2.30
      expect(breakdown.wearTearCost, equals(15.00)); // 10 * 1.50
      expect(breakdown.timeLaborCost, equals(82.00)); // 10 * 8.20
      expect(breakdown.isDrivingDistance, isTrue);
    });

    test('Computes exact travel fee for zero distance (at breakdown site dispatch)', () {
      final config = TravelPricingConfig.defaultConfig();

      final breakdown = PricingConfigService.calculateTravelFee(
        distanceKm: 0.0,
        config: config,
      );

      expect(breakdown.distanceCharge, equals(0.00));
      expect(breakdown.baseDispatchFee, equals(50.00));
      expect(breakdown.totalFee, equals(50.00));
      expect(breakdown.fuelCost, equals(0.00));
    });

    test('Supports dynamic pricing config adjustment (e.g. petrol price hike)', () {
      const adjustedConfig = TravelPricingConfig(
        perKmRate: 24.50,
        baseDispatchFee: 65.00,
        fuelCostPerKm: 2.80,
        wearTearCostPerKm: 1.70,
        timeLaborCompensationPerKm: 9.00,
      );

      const distance = 15.0;
      final breakdown = PricingConfigService.calculateTravelFee(
        distanceKm: distance,
        config: adjustedConfig,
      );

      // 65.00 + (15.0 * 24.50) = 65.00 + 367.50 = 432.50
      expect(breakdown.baseDispatchFee, equals(65.00));
      expect(breakdown.distanceCharge, equals(367.50));
      expect(breakdown.totalFee, equals(432.50));
      expect(breakdown.fuelCost, equals(42.00)); // 15 * 2.80
    });

    test('Serializes to Firestore Map and deserializes cleanly without data loss', () {
      const original = TravelFeeBreakdown(
        distanceKm: 7.4,
        baseDispatchFee: 50.0,
        perKmRate: 20.0,
        distanceCharge: 148.0,
        totalFee: 198.0,
        fuelCost: 17.02,
        wearTearCost: 11.10,
        timeLaborCost: 60.68,
        isDrivingDistance: true,
      );

      final map = original.toMap();
      expect(map['distanceKm'], equals(7.4));
      expect(map['totalFee'], equals(198.0));
      expect(map['isDrivingDistance'], isTrue);

      final restored = TravelFeeBreakdown.fromMap(map);
      expect(restored.distanceKm, equals(original.distanceKm));
      expect(restored.totalFee, equals(original.totalFee));
      expect(restored.distanceCharge, equals(original.distanceCharge));
      expect(restored.fuelCost, closeTo(original.fuelCost, 0.001));
    });
  });
}

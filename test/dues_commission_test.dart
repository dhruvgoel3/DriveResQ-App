import 'package:flutter_test/flutter_test.dart';
import 'package:driveresq_app/modules/dues/utils/commission_calculator.dart';

void main() {
  group('Platform Dues & Commission Math Tests', () {
    test('Calculates 10% commission on standard labor: ₹1000 -> ₹100 (10000 paise)', () {
      final result = computeCommission(1000.0, 10.0);
      expect(result.amount, equals(100.0));
      expect(result.amountPaise, equals(10000));
      expect(result.laborCharges, equals(1000.0));
      expect(result.commissionPercent, equals(10.0));
    });

    test('Zero labor charges result in zero commission and zero paise: ₹0 -> ₹0', () {
      final result = computeCommission(0.0, 10.0);
      expect(result.amount, equals(0.0));
      expect(result.amountPaise, equals(0));
    });

    test('Negative labor charges result in zero commission: -₹50 -> ₹0', () {
      final result = computeCommission(-50.0, 10.0);
      expect(result.amount, equals(0.0));
      expect(result.amountPaise, equals(0));
    });

    test('Decimal precision rounds accurately: ₹333 at 10% -> ₹33.30 (3330 paise)', () {
      final result = computeCommission(333.0, 10.0);
      expect(result.amount, equals(33.30));
      expect(result.amountPaise, equals(3330));
    });

    test('Exact product example: labor ₹1000, parts ₹500, travel ₹100, total cash ₹1600', () {
      const labor = 1000.0;
      const parts = 500.0;
      const travel = 100.0;
      const totalCash = labor + parts + travel; // 1600.0

      final dueResult = computeCommission(labor, 10.0);
      final mechanicKeeps = totalCash - dueResult.amount;

      expect(dueResult.amount, equals(100.0));
      expect(mechanicKeeps, equals(1500.0));
    });

    test('Calculates custom commission percent accurately: ₹500 at 15% -> ₹75.0', () {
      final result = computeCommission(500.0, 15.0);
      expect(result.amount, equals(75.0));
      expect(result.amountPaise, equals(7500));
    });

    test('Helper functions computeCommissionAmount and computeCommissionPaise work', () {
      expect(computeCommissionAmount(1000.0, 10.0), equals(100.0));
      expect(computeCommissionPaise(1000.0, 10.0), equals(10000));
    });
  });
}

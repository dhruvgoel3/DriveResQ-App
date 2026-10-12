/// Pure calculation utilities for DriveResQ Platform Dues & Commission.
/// Server-side Cloud Functions independently enforce these calculations,
/// but this client utility is used for preview calculations and unit tests.
class CommissionCalculation {
  final double amount;
  final int amountPaise;
  final double laborCharges;
  final double commissionPercent;

  const CommissionCalculation({
    required this.amount,
    required this.amountPaise,
    required this.laborCharges,
    required this.commissionPercent,
  });

  @override
  String toString() =>
      'CommissionCalculation(amount: $amount, paise: $amountPaise, labor: $laborCharges, percent: $commissionPercent)';
}

/// Computes the platform commission for labor charges.
/// Commission applies ONLY to labor charges; parts, travel, and base charges stay 100% with the mechanic.
CommissionCalculation computeCommission(
  double laborCharges, [
  double percent = 10.0,
]) {
  if (laborCharges <= 0 || percent <= 0) {
    return const CommissionCalculation(
      amount: 0.0,
      amountPaise: 0,
      laborCharges: 0.0,
      commissionPercent: 0.0,
    );
  }

  // Exact 2-decimal rounding matching Cloud Functions Math.round(val * 100) / 100
  final rawAmount = (laborCharges * percent) / 100.0;
  final roundedAmount = double.parse(rawAmount.toStringAsFixed(2));
  final amountPaise = (roundedAmount * 100).round();

  return CommissionCalculation(
    amount: roundedAmount,
    amountPaise: amountPaise,
    laborCharges: laborCharges,
    commissionPercent: percent,
  );
}

double computeCommissionAmount(double laborCharges, [double percent = 10.0]) =>
    computeCommission(laborCharges, percent).amount;

int computeCommissionPaise(double laborCharges, [double percent = 10.0]) =>
    computeCommission(laborCharges, percent).amountPaise;

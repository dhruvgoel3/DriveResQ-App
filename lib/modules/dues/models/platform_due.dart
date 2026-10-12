import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformDue {
  final String id;
  final String mechanicId;
  final String jobId;
  final String invoiceNumber;
  final double laborCharges;
  final double commissionPercent;
  final double amount;
  final int amountPaise;
  final String currency;
  final String status; // 'unpaid' | 'paid'
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;

  const PlatformDue({
    required this.id,
    required this.mechanicId,
    required this.jobId,
    required this.invoiceNumber,
    required this.laborCharges,
    required this.commissionPercent,
    required this.amount,
    required this.amountPaise,
    this.currency = 'INR',
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
  });

  bool get isPaid => status == 'paid';
  bool get isUnpaid => status == 'unpaid';

  factory PlatformDue.fromMap(Map<String, dynamic> map, {required String docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    final labor = (map['laborCharges'] as num?)?.toDouble() ?? 0.0;
    final percent = (map['commissionPercent'] as num?)?.toDouble() ?? 10.0;
    final amt = (map['amount'] as num?)?.toDouble() ?? 0.0;
    final paise = (map['amountPaise'] as num?)?.toInt() ?? (amt * 100).round();

    return PlatformDue(
      id: docId,
      mechanicId: map['mechanicId'] as String? ?? '',
      jobId: map['jobId'] as String? ?? docId,
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      laborCharges: labor,
      commissionPercent: percent,
      amount: amt,
      amountPaise: paise,
      currency: map['currency'] as String? ?? 'INR',
      status: map['status'] as String? ?? 'unpaid',
      createdAt: parseDate(map['createdAt']),
      paidAt: parseNullableDate(map['paidAt']),
      razorpayPaymentId: map['razorpayPaymentId'] as String?,
      razorpayOrderId: map['razorpayOrderId'] as String?,
      razorpaySignature: map['razorpaySignature'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mechanicId': mechanicId,
      'jobId': jobId,
      'invoiceNumber': invoiceNumber,
      'laborCharges': laborCharges,
      'commissionPercent': commissionPercent,
      'amount': amount,
      'amountPaise': amountPaise,
      'currency': currency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
    };
  }
}

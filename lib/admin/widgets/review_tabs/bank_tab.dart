import 'package:flutter/material.dart';
import 'review_helpers.dart';

class BankTab extends StatelessWidget {
  final Map<String, dynamic> mechanicData;

  const BankTab({super.key, required this.mechanicData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ReviewHelpers.buildCard([
        ReviewHelpers.buildSecureField(
          'Account Holder',
          mechanicData['bankAccountHolder'],
        ),
        ReviewHelpers.buildSecureField(
          'Account Number',
          mechanicData['bankAccountNumber'],
          mask: true,
        ),
        ReviewHelpers.buildField('IFSC Code', mechanicData['bankIfsc']),
        ReviewHelpers.buildField('Bank Name', mechanicData['bankName']),
        ReviewHelpers.buildField(
          'UPI ID',
          mechanicData['upiId'] ?? 'Not provided',
        ),
      ]),
    );
  }
}

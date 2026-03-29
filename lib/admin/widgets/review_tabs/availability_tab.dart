import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'review_helpers.dart';

class AvailabilityTab extends StatelessWidget {
  final Map<String, dynamic> mechanicData;

  const AvailabilityTab({super.key, required this.mechanicData});

  @override
  Widget build(BuildContext context) {
    final days = (mechanicData['availableDays'] as List?)?.cast<String>() ?? [];
    final hours = mechanicData['workingHours'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ReviewHelpers.buildCard([
        ReviewHelpers.buildField(
          'Working Hours',
          '${hours['start'] ?? '?'} — ${hours['end'] ?? '?'}',
        ),
        const SizedBox(height: 12),
        Text('Available Days', style: ReviewHelpers.labelStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days
              .map(
                (d) => Chip(
                  label: Text(d, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: Colors.green.shade50,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        ReviewHelpers.buildField(
          'Service Radius',
          '${mechanicData['serviceRadius'] ?? 0} km',
        ),
        ReviewHelpers.buildField(
          'Base Charge',
          '₹${mechanicData['baseCharge'] ?? 0}',
        ),
        ReviewHelpers.buildField(
          'Per KM Charge',
          '₹${mechanicData['perKmCharge'] ?? 0}',
        ),
        ReviewHelpers.buildField(
          'Emergency Surcharge',
          '${mechanicData['emergencySurcharge'] ?? 0}%',
        ),
      ]),
    );
  }
}

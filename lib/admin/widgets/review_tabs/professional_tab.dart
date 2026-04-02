import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'review_helpers.dart';

class ProfessionalTab extends StatelessWidget {
  final Map<String, dynamic> mechanicData;

  const ProfessionalTab({super.key, required this.mechanicData});

  @override
  Widget build(BuildContext context) {
    final specializations =
        (mechanicData['specializations'] as List?)?.cast<String>() ?? [];
    final services =
        (mechanicData['servicesOffered'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ReviewHelpers.buildCard([
        ReviewHelpers.buildField('Shop Name', mechanicData['shopName']),
        ReviewHelpers.buildField('Shop Address', mechanicData['shopAddress']),
        ReviewHelpers.buildField(
          'Years of Experience',
          '${mechanicData['experience'] ?? 0} years',
        ),
        const SizedBox(height: 12),
        Text('Specializations', style: ReviewHelpers.labelStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specializations
              .map(
                (s) => Chip(
                  label: Text(s, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Text('Services Offered', style: ReviewHelpers.labelStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services
              .map(
                (s) => Chip(
                  label: Text(s, style: GoogleFonts.poppins(fontSize: 12)),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
        if ((mechanicData['shopPhotoUrl'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Shop Photo', style: ReviewHelpers.labelStyle()),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: mechanicData['shopPhotoUrl'],
              width: 400,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (c,u) => Container(width: 400, height: 250, color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
            ),
          ),
        ],
      ]),
    );
  }
}

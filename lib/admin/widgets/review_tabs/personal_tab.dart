import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'review_helpers.dart';

class PersonalTab extends StatelessWidget {
  final Map<String, dynamic> mechanicData;

  const PersonalTab({super.key, required this.mechanicData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ReviewHelpers.buildCard([
        ReviewHelpers.buildField('Full Name', mechanicData['fullName']),
        ReviewHelpers.buildField('Date of Birth', mechanicData['dob'] ?? 'N/A'),
        ReviewHelpers.buildField('Gender', mechanicData['gender']),
        ReviewHelpers.buildField(
          'Email',
          mechanicData['email'] ?? 'Not provided',
        ),
        if ((mechanicData['profilePhotoUrl'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Profile Photo', style: ReviewHelpers.labelStyle()),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: mechanicData['profilePhotoUrl'],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (c,u) => Container(width: 200, height: 200, color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
            ),
          ),
        ],
      ]),
    );
  }
}

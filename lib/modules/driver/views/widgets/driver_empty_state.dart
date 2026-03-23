import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

/// Beautiful empty state for driver home — shown when no active request.
class DriverEmptyState extends StatelessWidget {
  final VoidCallback onNewRequest;

  DriverEmptyState({super.key, required this.onNewRequest});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Iconsax.car,
      iconColor: Color(0xFF6C63FF),
      title: 'Need Roadside Help?',
      message:
          'Your vehicle status is clear. Need help?\nTap the button below to request assistance.',
      tips: [
        '⚡ Average response time: ~5 minutes',
        '🔒 All mechanics are verified & trusted',
        '📍 Track your mechanic in real time',
        '💬 Chat directly with your mechanic',
      ],
      buttonText: '🚗  Request Assistance',
      onButtonPressed: onNewRequest,
    );
  }
}

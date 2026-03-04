import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

/// Beautiful empty state for driver home — shown when no active request.
class DriverEmptyState extends StatelessWidget {
  final VoidCallback onNewRequest;

  const DriverEmptyState({super.key, required this.onNewRequest});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.directions_car,
      iconColor: const Color(0xFF6C63FF),
      title: 'No Active Requests',
      message:
          'Need roadside assistance?\nCreate a request and get help from nearby mechanics!',
      buttonText: 'Create Request',
      onButtonPressed: onNewRequest,
      tips: const [
        'Average response time: ~5 minutes',
        'Verified mechanics near you 24/7',
        'Track your mechanic in real time',
      ],
    );
  }
}

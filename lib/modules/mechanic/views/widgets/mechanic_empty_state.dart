import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

/// Beautiful empty state for mechanic home — shown when no nearby requests.
class MechanicEmptyState extends StatelessWidget {
  const MechanicEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.build_circle,
      iconColor: Color(0xFFFF9800),
      title: 'No Nearby Requests',
      message:
          "Don't worry! Requests will appear when drivers need help in your area.",
      tips: [
        'Make sure you are online',
        'Check your service radius settings',
        'Peak hours: 10AM–2PM, 5PM–8PM',
      ],
    );
  }
}

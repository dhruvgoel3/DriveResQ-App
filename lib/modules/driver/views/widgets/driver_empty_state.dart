import 'package:flutter/material.dart';

class DriverEmptyState extends StatelessWidget {
  final VoidCallback onNewRequest;

  const DriverEmptyState({
    super.key,
    required this.onNewRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼️ Illustration placeholder
                Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_car_filled,
                      size: 80,
                      color: Colors.amber,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Everything looks good!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Your vehicle status is clear.\nNeed help? Tap the button below to request assistance.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ➕ Floating action button
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: onNewRequest,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

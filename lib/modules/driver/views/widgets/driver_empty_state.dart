import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverEmptyState extends StatelessWidget {
  final VoidCallback onNewRequest;

  const DriverEmptyState({super.key, required this.onNewRequest});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 140),
              child: Column(
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

                  Text(
                    "Everything looks good!",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Your vehicle status is clear.\nNeed help? Tap the button below to request assistance.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ➕ Floating action button
        Positioned(
          bottom: 30,
          right: 30,
          child: FloatingActionButton(
            shape: CircleBorder(), // ✅ correct
            backgroundColor: Color(0xFF6C63FF), //
            onPressed: onNewRequest,
            child: const Icon(
              Icons.add,
              color: Colors.white, // better contrast
            ),
          ),
        ),
      ],
    );
  }
}

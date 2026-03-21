import 'package:flutter/material.dart';

class MechanicsMapView extends StatelessWidget {
  const MechanicsMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold is handled by the parent view, this is just a widget placeholder
    return Container(
      color: Colors.grey.shade200,
      margin: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
           "Google Maps integration requires the google_maps_flutter package.\n"
           "Map View is currently under construction until API keys are provided.",
           textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverMapWidget extends StatelessWidget {
  const DriverMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // 🔥 REQUIRED
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(40.7128, -74.0060), // replace with driver location
            zoom: 12,
          ),
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          markers: {
            Marker(
              markerId: const MarkerId("mechanic"),
              position: const LatLng(40.715, -74.002),
              infoWindow: const InfoWindow(title: "Mechanic En Route"),
            ),
          },
        ),
      ),
    );
  }
}

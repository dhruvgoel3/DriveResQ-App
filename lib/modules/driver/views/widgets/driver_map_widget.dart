import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class DriverMapWidget extends StatelessWidget {
  const DriverMapWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.h, // 🔥 REQUIRED
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(40.7128, -74.0060), // replace with driver location
            zoom: 12,
          ),
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          markers: {
            Marker(
              markerId: MarkerId("mechanic"),
              position: LatLng(40.715, -74.002),
              infoWindow: InfoWindow(title: "Mechanic En Route"),
            ),
          },
        ),
      ),
    );
  }
}

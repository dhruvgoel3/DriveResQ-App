import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/helpers/map_navigation_helper.dart';
import '../controllers/live_tracking_controller.dart';

class LiveTrackingView extends StatelessWidget {
  final String requestId;
  final String role; // 'mechanic' only should open this

  const LiveTrackingView({
    super.key,
    required this.requestId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveTrackingController(requestId, role));

    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
      body: Obx(() {
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(20.5937, 78.9629),
                zoom: 5,
              ),
              markers: {
                if (controller.driverMarker.value != null)
                  controller.driverMarker.value!,
                if (controller.mechanicMarker.value != null)
                  controller.mechanicMarker.value!,
              },
              onMapCreated: (map) {
                controller.mapController = map;
              },

              // 🔒 DRIVER IS VIEW-ONLY
              myLocationEnabled: role == 'mechanic',
              myLocationButtonEnabled: role == 'mechanic',
            ),

            // 🚀 NAVIGATION BUTTON (MECHANIC ONLY)
            if (role == 'mechanic')
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation, color: Colors.white),
                  label: Text(
                    "Start Navigating",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final origin = controller.mechanicLatLng;
                    final destination = controller.driverLatLng;

                    if (origin == null || destination == null) {
                      Get.snackbar("Error", "Location not ready");
                      return;
                    }

                    MapsNavigationHelper.startNavigation(
                      originLat: origin.latitude,
                      originLng: origin.longitude,
                      destLat: destination.latitude,
                      destLng: destination.longitude,
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}

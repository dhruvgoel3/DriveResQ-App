import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/live_tracking_controller.dart';

class LiveTrackingView extends StatelessWidget {
  final String requestId;

  const LiveTrackingView({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.put(LiveTrackingController(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
      body: Obx(() {
        return GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(20.5937, 78.9629), // India
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
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        );
      }),
    );
  }
}

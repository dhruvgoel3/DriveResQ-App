import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../modules/tracking/views/live_tracking_view.dart';
import '../helpers/call_helper.dart';

class ActiveRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const ActiveRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final String status = request['status'] ?? 'pending';

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔰 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Active Request",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _statusChip(status),
              ],
            ),

            SizedBox(height: 20),

            // 🗺️ MAP VIEW (PLACEHOLDER / REAL MAP)
            _mapPreview(status),

            SizedBox(height: 23),

            // 📍 INFO SECTION
            _infoTile(
              icon: Icons.location_on,
              title: request['locationName'],
              subtitle: "Pickup Location",
            ),
            SizedBox(height: 10),

            _infoTile(
              icon: Icons.directions_car,
              title: request['vehicleType'],
              subtitle: "Vehicle Details",
            ),
            SizedBox(height: 10),

            _infoTile(
              icon: Icons.warning_amber_rounded,
              title: request['problem'],
              subtitle: "Reported Issue",
            ),

            const SizedBox(height: 10),

            // 📞 ACTIONS (ONLY AFTER ACCEPTED)
            if (status == 'accepted') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    CallHelper.callNumber(request['mechanicPhone'] ?? '');
                  },
                  icon: const Icon(Icons.call),
                  label: const Text("Call Mechanic"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.to(() => LiveTrackingView(requestId: request['id']));
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text("Navigate / Track"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🟢 STATUS CHIP
  Widget _statusChip(String status) {
    final bool accepted = status == 'accepted';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accepted
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: accepted ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  // 🗺️ MAP VIEW (INSIDE CARD)
  Widget _mapPreview(String status) {
    if (status != 'accepted') {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: const Center(
          child: Icon(Icons.map, size: 40, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (controller) async {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );

            controller.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(position.latitude, position.longitude),
                15,
              ),
            );
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0), // temporary
            zoom: 1,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  // 📌 INFO TILE
  Widget _infoTile({
    required IconData icon,
    required String? title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "N/A",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../tracking/views/live_tracking_view.dart';
import '../../../../utils/helpers/call_helper.dart';

class ActiveRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const ActiveRequestCard({super.key, required this.request});

  static const Color primaryColor = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final status = request['status'];




    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔰 HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Active Request",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                _acceptedChip(),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 🗺️ MAP
          _mapSection(),

          const SizedBox(height: 16),

          // 📍 LOCATION
          _infoTile(
            icon: Icons.location_on_outlined,
            title: request['locationName'] ?? 'Location',
            subtitle: "Pickup Location",
          ),

          _infoTile(
            icon: Icons.directions_car,
            title: request['vehicleType'] ?? 'Vehicle',
            subtitle: "Vehicle Details",
          ),

          _infoTile(
            icon: Icons.report_problem_outlined,
            title: request['problem'] ?? 'Issue',
            subtitle: "Reported Issue",
          ),

          const SizedBox(height: 18),

          // 📞 CALL BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                CallHelper.callNumber(request['mechanicPhone'] ?? 'driver');
              },
              icon: const Icon(Icons.call, size: 18),
              label: const Text("Call Mechanic"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

           SizedBox(height: 12),

          // 🧭 NAVIGATE BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.to(
                  () => LiveTrackingView(requestId: request['id'], role: ''),
                );
              },
              icon: const Icon(Icons.navigation, size: 18),
              label: const Text("Track Mechanic"),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 ACCEPTED CHIP
  Widget _acceptedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Accepted",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.green,
        ),
      ),
    );
  }

  // 🗺️ MAP WITH OVERLAY
  Widget _mapSection() {
    return SizedBox(
      height: 170,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              onMapCreated: (controller) async {
                final pos = await Geolocator.getCurrentPosition();
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(pos.latitude, pos.longitude),
                    15,
                  ),
                );
              },
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),

            // 🚗 MECHANIC EN ROUTE LABEL
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.directions_car, size: 14, color: primaryColor),
                    SizedBox(width: 6),
                    Text(
                      "MECHANIC EN ROUTE",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 INFO TILE
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

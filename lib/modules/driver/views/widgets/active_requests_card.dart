import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../tracking/views/live_tracking_view.dart';

class ActiveRequestCard extends StatefulWidget {
  final Map<String, dynamic> request;

  const ActiveRequestCard({super.key, required this.request});

  @override
  State<ActiveRequestCard> createState() => _ActiveRequestCardState();
}

class _ActiveRequestCardState extends State<ActiveRequestCard> {
  static const Color primaryColor = Color(0xFF6C63FF);

  GoogleMapController? _mapController;
  double? mechanicLat;
  double? mechanicLng;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.request['status'] == 'accepted') {
      _listenToMechanicLocation();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Listen to mechanic's real-time location
  void _listenToMechanicLocation() {
    final mechanicId = widget.request['mechanicId'];
    if (mechanicId == null) return;

    FirebaseFirestore.instance
        .collection('mechanic_locations')
        .doc(mechanicId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || !mounted) return;

      final data = snapshot.data()!;
      final lat = data['latitude'];
      final lng = data['longitude'];

      if (lat != null && lng != null) {
        setState(() {
          mechanicLat = lat;
          mechanicLng = lng;
          _updateMarkers();
        });

        // Move camera to mechanic location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(mechanicLat!, mechanicLng!),
            14,
          ),
        );
      }
    });
  }

  // Update map markers
  void _updateMarkers() {
    if (mechanicLat == null || mechanicLng == null) return;

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('mechanic'),
          position: LatLng(mechanicLat!, mechanicLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Mechanic'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.request['status'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                _statusChip(status),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 🗺️ MAP PREVIEW (NEW!)
          if (status == 'accepted') _buildMapPreview(),
          if (status == 'accepted') const SizedBox(height: 14),

          // 📍 LOCATION
          _infoTile(
            icon: Icons.location_on_outlined,
            title: widget.request['locationName'] ?? 'Location',
            subtitle: "Pickup Location",
          ),

          _infoTile(
            icon: Icons.directions_car,
            title: widget.request['vehicleType'] ?? 'Vehicle',
            subtitle: "Vehicle Details",
          ),

          _infoTile(
            icon: Icons.report_problem_outlined,
            title: widget.request['problem'] ?? 'Issue',
            subtitle: "Reported Issue",
          ),

          const SizedBox(height: 18),

          // Show different buttons based on status
          if (status == 'accepted') ...[
            // 📞 CALL BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _callMechanic(widget.request['mechanicPhone']),
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

            const SizedBox(height: 12),

            // 🧭 TRACK MECHANIC BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => LiveTrackingView(requestId: widget.request['id']));
                },
                icon: const Icon(Icons.location_searching, size: 18),
                label: const Text("Track Mechanic Live"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ] else ...[
            // For 'open' status - show waiting message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Waiting for a mechanic to accept your request...",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 🗺️ MAP PREVIEW WIDGET (NEW!)
  Widget _buildMapPreview() {
    return GestureDetector(
      onTap: () {
        // Open full tracking view when map is tapped
        Get.to(() => LiveTrackingView(requestId: widget.request['id']));
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Google Map
              mechanicLat != null && mechanicLng != null
                  ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(mechanicLat!, mechanicLng!),
                  zoom: 14,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                mapToolbarEnabled: false,
              )
                  : Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        "Loading mechanic location...",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tap to view indicator
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Tap to view",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Mechanic en route label
              if (mechanicLat != null && mechanicLng != null)
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "MECHANIC EN ROUTE",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🟢 STATUS CHIP
  Widget _statusChip(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        text = "Accepted";
        break;
      case 'open':
        color = Colors.orange;
        text = "Waiting";
        break;
      case 'completed':
        color = Colors.blue;
        text = "Completed";
        break;
      default:
        color = Colors.grey;
        text = "Unknown";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
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

  // 📞 Call mechanic
  void _callMechanic(String? phone) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar("Error", "Mechanic phone number not available");
      return;
    }

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Cannot make call");
    }
  }
}
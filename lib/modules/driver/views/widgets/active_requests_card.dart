import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../tracking/views/live_tracking_view.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class ActiveRequestCard extends StatefulWidget {
  final Map<String, dynamic> request;


  ActiveRequestCard({super.key, required this.request});

  @override
  State<ActiveRequestCard> createState() => _ActiveRequestCardState();
}

class _ActiveRequestCardState extends State<ActiveRequestCard> {
  static Color primaryColor = Color(0xFF6C63FF);

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
          markerId: MarkerId('mechanic'),
          position: LatLng(mechanicLat!, mechanicLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Mechanic'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.request['status'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔰 HEADER
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Active Request",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                _statusChip(status),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // 🗺️ MAP PREVIEW (NEW!)
          if (status == 'accepted') _buildMapPreview(),
          if (status == 'accepted') SizedBox(height: 14.h),

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

          SizedBox(height: 18.h),

          // Show different buttons based on status
          if (status == 'accepted') ...[
            // 📞 CALL BUTTON
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: () => _callMechanic(widget.request['mechanicPhone']),
                icon: Icon(Icons.call, size: 18.w),
                label: Text("Call Mechanic"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // 🧭 TRACK MECHANIC BUTTON
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => LiveTrackingView(requestId: widget.request['id']));
                },
                icon: Icon(Icons.location_searching, size: 18.w),
                label: Text("Track Mechanic Live"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ] else ...[
            // For 'open' status - show waiting message
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Colors.orange),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Waiting for a mechanic to accept your request...",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
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
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
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
                      CircularProgressIndicator(),
                      SizedBox(height: 12.h),
                      Text(
                        "Loading mechanic location...",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tap to view indicator
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20.r),
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
                      Icon(
                        Icons.touch_app,
                        size: 14.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "Tap to view",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
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
                  left: 12.w,
                  bottom: 12.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
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
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "MECHANIC EN ROUTE",
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: primaryColor, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
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

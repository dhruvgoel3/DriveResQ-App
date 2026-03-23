import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../chat/controllers/chat_controller.dart';
import '../../../chat/views/chat_screen.dart';
import '../../../tracking/views/live_tracking_view.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import '../../services/driver_service.dart';

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
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.request['status'] == 'accepted') {
      _listenToMechanicLocation();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Listen to mechanic's real-time location
  void _listenToMechanicLocation() {
    final mechanicId = widget.request['mechanicId'];
    if (mechanicId == null) return;

    _locationSubscription?.cancel();
    _locationSubscription = DriverService.getMechanicLocationStream(mechanicId)
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
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
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
            title: (widget.request['locationName'] ?? '').toString().isEmpty
                ? 'Location not available'
                : widget.request['locationName'],
            subtitle: "Pickup Location",
          ),

          _infoTile(
            icon: Icons.directions_car,
            title: (widget.request['vehicleType'] ?? '').toString().isEmpty
                ? 'Not specified'
                : widget.request['vehicleType'],
            subtitle: "Vehicle Type",
          ),

          _infoTile(
            icon: Icons.report_problem_outlined,
            title: (widget.request['problem'] ?? '').toString().isEmpty
                ? 'Not specified'
                : widget.request['problem'],
            subtitle: "Reported Issue",
          ),

          if ((widget.request['landmark'] ?? '').toString().isNotEmpty)
            _infoTile(
              icon: Icons.pin_drop_outlined,
              title: widget.request['landmark'],
              subtitle: "Nearby Landmark",
            ),

          // Verification code display (for accepted requests)
          if (status == 'accepted' &&
              widget.request['verificationCode'] != null)
            _buildVerificationCode(),

          if (status == 'accepted' &&
              widget.request['verificationCode'] != null)
            SizedBox(height: 14.h),

          SizedBox(height: 18.h),

          // Show different buttons based on status
          if (status == 'accepted') ...[
            // 📞 CALL AND CHAT BUTTONS
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () => _callMechanic(widget.request['mechanicPhone']),
                      icon: Icon(Icons.call, size: 18.w),
                      label: Text("Call"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: _openChat,
                      icon: Icon(Icons.chat_bubble, size: 18.w),
                      label: Text("Chat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 🧭 TRACK MECHANIC BUTTON
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(
                    () => LiveTrackingView(requestId: widget.request['id']),
                  );
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
                      Icon(Icons.touch_app, size: 14.w, color: Colors.white),
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
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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

  // 🔐 Verification code display
  Widget _buildVerificationCode() {
    final code = widget.request['verificationCode'] as String;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.08),
            primaryColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: primaryColor, size: 20.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Verification Code",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "Share this code with the mechanic to confirm job completion",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 14.h),
          // Code digits
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.split('').map((digit) {
              return Flexible(
                child: Container(
                  width: 40.w,
                  height: 48.h,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      digit,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 14.h),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    Get.snackbar(
                      "Copied!",
                      "Verification code copied to clipboard",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green.withOpacity(0.9),
                      colorText: Colors.white,
                    );
                  },
                  icon: Icon(Icons.copy, size: 16.w),
                  label: Text(
                    "Copy",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final mechanicPhone = widget.request['mechanicPhone'];
                    if (mechanicPhone != null) {
                      final uri = Uri.parse(
                        'sms:$mechanicPhone?body=Your DriveResQ verification code is: $code',
                      );
                      launchUrl(uri);
                    } else {
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Your DriveResQ verification code is: $code',
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.share, size: 16.w),
                  label: Text(
                    "Share",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 💬 Open Chat
  void _openChat() {
    final chatId = widget.request['id'] ?? '';
    if (chatId.isEmpty) {
      Get.snackbar('Error', 'Chat not available yet');
      return;
    }
    
    Get.delete<ChatController>(force: true);
    Get.put(
      ChatController(
        chatId: chatId,
        otherUserName: widget.request['mechanicName'] ?? 'Mechanic',
        otherUserPhoto: widget.request['mechanicPhoto'] ?? '',
        myRole: 'driver',
      ),
    );
    
    Get.to(
      () => ChatScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class LiveTrackingView extends StatefulWidget {
  final String requestId;

  LiveTrackingView({super.key, required this.requestId});

  @override
  State<LiveTrackingView> createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends State<LiveTrackingView> {
  GoogleMapController? _mapController;

  // Locations
  double? driverLat;
  double? driverLng;
  double? mechanicLat;
  double? mechanicLng;

  // Map markers
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Real-time listeners
  StreamSubscription? _mechanicLocationSubscription;
  StreamSubscription? _requestSubscription;

  // UI state
  String distance = "Calculating...";
  String eta = "...";
  bool isLoading = true;
  String mechanicPhone = "";
  String status = "accepted";

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _mechanicLocationSubscription?.cancel();
    _requestSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // 🚀 Initialize tracking
  Future<void> _initializeTracking() async {
    await _getDriverLocation();
    _listenToRequestUpdates();
  }

  // 📍 Get driver's current location
  Future<void> _getDriverLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        driverLat = position.latitude;
        driverLng = position.longitude;
        isLoading = false;
      });

      _updateDriverMarker();
    } catch (e) {
      print("❌ Error getting driver location: $e");
      Get.snackbar("Error", "Could not get your location");
    }
  }

  // 🎧 Listen to request updates (to get mechanic location)
  void _listenToRequestUpdates() {
    _requestSubscription = FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists) return;

          final data = snapshot.data()!;
          final mechanicId = data['mechanicId'];
          status = data['status'] ?? 'accepted';
          mechanicPhone = data['mechanicPhone'] ?? '';

          if (status == 'completed' || status == 'cancelled') {
            Get.back();
            Get.snackbar(
              "Request ${status.capitalize}",
              "This request has been $status",
            );
            return;
          }

          if (mechanicId != null) {
            _listenToMechanicLocation(mechanicId);
          }
        });
  }

  // 🎧 Listen to mechanic's real-time location
  void _listenToMechanicLocation(String mechanicId) {
    _mechanicLocationSubscription?.cancel();

    _mechanicLocationSubscription = FirebaseFirestore.instance
        .collection('mechanic_locations')
        .doc(mechanicId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists) {
            print("⚠️ Mechanic location not available");
            return;
          }

          final data = snapshot.data()!;
          final lat = data['latitude'];
          final lng = data['longitude'];

          if (lat != null && lng != null) {
            setState(() {
              mechanicLat = lat;
              mechanicLng = lng;
            });

            _updateMechanicMarker();
            _updateRoute();
            _calculateDistanceAndETA();
            _moveCameraToShowBoth();
          }
        });
  }

  // 📍 Update driver marker
  void _updateDriverMarker() {
    if (driverLat == null || driverLng == null) return;

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: LatLng(driverLat!, driverLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  // 📍 Update mechanic marker
  void _updateMechanicMarker() {
    if (mechanicLat == null || mechanicLng == null) return;

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'mechanic');
      _markers.add(
        Marker(
          markerId: MarkerId('mechanic'),
          position: LatLng(mechanicLat!, mechanicLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: 'Mechanic Location'),
        ),
      );
    });
  }

  // 🛣️ Update route line
  void _updateRoute() {
    if (driverLat == null ||
        driverLng == null ||
        mechanicLat == null ||
        mechanicLng == null) {
      return;
    }

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: [
            LatLng(mechanicLat!, mechanicLng!),
            LatLng(driverLat!, driverLng!),
          ],
          color: Color(0xFF6C63FF),
          width: 4.w.toInt(),
        ),
      );
    });
  }

  // 📏 Calculate distance and ETA
  void _calculateDistanceAndETA() {
    if (driverLat == null ||
        driverLng == null ||
        mechanicLat == null ||
        mechanicLng == null) {
      return;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      mechanicLat!,
      mechanicLng!,
      driverLat!,
      driverLng!,
    );

    double distanceInKm = distanceInMeters / 1000;

    // Calculate ETA (assuming average speed of 40 km/h in city)
    double timeInHours = distanceInKm / 40;
    int timeInMinutes = (timeInHours * 60).round();

    setState(() {
      distance = distanceInKm < 1
          ? "${distanceInMeters.toStringAsFixed(0)} m"
          : "${distanceInKm.toStringAsFixed(1)} km";

      eta = timeInMinutes < 1 ? "< 1 min" : "$timeInMinutes min";
    });
  }

  // 📷 Move camera to show both markers
  void _moveCameraToShowBoth() {
    if (_mapController == null ||
        driverLat == null ||
        driverLng == null ||
        mechanicLat == null ||
        mechanicLng == null) {
      return;
    }

    double minLat = driverLat! < mechanicLat! ? driverLat! : mechanicLat!;
    double maxLat = driverLat! > mechanicLat! ? driverLat! : mechanicLat!;
    double minLng = driverLng! < mechanicLng! ? driverLng! : mechanicLng!;
    double maxLng = driverLng! > mechanicLng! ? driverLng! : mechanicLng!;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Track Mechanic",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 🗺️ Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(driverLat ?? 0, driverLng ?? 0),
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (mechanicLat != null && mechanicLng != null) {
                      _moveCameraToShowBoth();
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),

                // 📊 Info Card at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildInfoCard(),
                ),

                // 🎯 Center on location button
                Positioned(
                  right: 16.w,
                  bottom: 200.h,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _moveCameraToShowBoth,
                    child: Icon(Icons.my_location, color: Color(0xFF6C63FF)),
                  ),
                ),
              ],
            ),
    );
  }

  // 📊 Info card
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
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
                SizedBox(width: 8.w),
                Text(
                  "Mechanic En Route",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Distance and ETA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.location_on, distance, "Distance"),
              Container(width: 1, height: 40.h, color: Colors.grey.shade300),
              _buildStatItem(Icons.access_time, eta, "ETA"),
            ],
          ),

          SizedBox(height: 20.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callMechanic,
                  icon: Icon(Icons.call),
                  label: Text("Call"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF6C63FF),
                    side: BorderSide(color: Color(0xFF6C63FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openNavigation,
                  icon: Icon(Icons.navigation),
                  label: Text("Navigate"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF6C63FF)),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // 📞 Call mechanic
  void _callMechanic() async {
    if (mechanicPhone.isEmpty) {
      Get.snackbar("Error", "Mechanic phone number not available");
      return;
    }

    final uri = Uri.parse('tel:$mechanicPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Cannot make call");
    }
  }

  // 🗺️ Open navigation
  void _openNavigation() async {
    if (mechanicLat == null || mechanicLng == null) {
      Get.snackbar("Error", "Mechanic location not available");
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$mechanicLat,$mechanicLng',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Cannot open maps");
    }
  }
}

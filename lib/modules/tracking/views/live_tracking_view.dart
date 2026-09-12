import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
// Note: ensure FirebaseAuth is imported inside LiveTrackingController. Here we inject the controller.
import '../controllers/live_tracking_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTrackingView extends StatelessWidget {
  final String requestId;

  const LiveTrackingView({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    // Determine role dynamically before initializing controller if needed, or default as driver
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final role = (snapshot.data!.data() as Map<String, dynamic>?)?['role'] ?? 'driver';
        
        final controller = Get.put(LiveTrackingController(requestId, role), tag: requestId);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
              onPressed: () => Get.back(),
            ),
            title: Text(
              role == 'driver' ? "Track Mechanic" : "Track Driver",
              style: AppTextStyles.h2,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return Stack(
              children: [
                // 🗺️ Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: controller.driverLatLng ?? controller.mechanicLatLng ?? const LatLng(0, 0),
                    zoom: 14,
                  ),
                  markers: controller.markers.toSet(),
                  polylines: controller.polylines.toSet(),
                  onMapCreated: controller.onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),

                // 📊 Info Card at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildInfoCard(controller, role),
                ),

                // 🎯 Center on location button
                Positioned(
                  right: 16.w,
                  bottom: 220.h,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.surface,
                    onPressed: controller.moveCameraToShowBoth,
                    child: const Icon(Iconsax.gps, color: AppColors.primary),
                  ),
                ),
              ],
            );
          }),
        );
      }
    );
  }

  // 📊 Info card
  Widget _buildInfoCard(LiveTrackingController controller, String role) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
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
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  role == 'driver' ? "Mechanic En Route" : "Heading to Driver",
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
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
              _buildStatItem(Iconsax.location, controller.distanceLabel.value, "Distance"),
              Container(width: 1, height: 40.h, color: AppColors.border),
              _buildStatItem(Iconsax.clock, controller.etaLabel.value, "ETA"),
            ],
          ),

          SizedBox(height: 20.h),

          // Action buttons
          Row(
            children: [
              if (role == 'driver')
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.callMechanic,
                    icon: const Icon(Iconsax.call),
                    label: const Text("Call"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              if (role == 'driver') SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.openNavigation,
                  icon: const Icon(Iconsax.location),
                  label: const Text("Navigate"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
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
        Icon(icon, color: AppColors.primary),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

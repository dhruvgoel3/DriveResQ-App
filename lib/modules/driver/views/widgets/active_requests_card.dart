import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

import '../../../tracking/views/live_tracking_view.dart';
import '../../controllers/active_request_card_controller.dart';
import '../../controllers/driver_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  ActiveRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // Inject the controller uniquely for this request ID
    final controller = Get.put(
      ActiveRequestCardController(request),
      tag: request['id'] ?? 'active_req',
    );
    final status = request['status'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
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
          _Header(status: status),
          SizedBox(height: 14.h),

          // 🗺️ MAP PREVIEW
          if (status == 'accepted') _MapPreview(controller: controller, request: request),
          if (status == 'accepted') SizedBox(height: 14.h),

          // 🧑‍🔧 MECHANIC INFO
          if (request['mechanicId'] != null && status != 'open')
             _MechanicInfoTile(mechanicId: request['mechanicId'], mechanicName: request['mechanicName'] ?? 'Mechanic'),
          if (request['mechanicId'] != null && status != 'open') SizedBox(height: 14.h),

          // 📍 INFO TILES
          _InfoTile(
            icon: Iconsax.location,
            title: (request['locationName'] ?? '').toString().isEmpty ? 'Location not available' : request['locationName'],
            subtitle: "Pickup Location",
          ),
          _InfoTile(
            icon: Iconsax.car,
            title: (request['vehicleType'] ?? '').toString().isEmpty ? 'Not specified' : request['vehicleType'],
            subtitle: "Vehicle Type",
          ),
          _InfoTile(
            icon: Iconsax.warning_2,
            title: (request['problem'] ?? '').toString().isEmpty ? 'Not specified' : request['problem'],
            subtitle: "Reported Issue",
          ),
          if ((request['landmark'] ?? '').toString().isNotEmpty)
            _InfoTile(
              icon: Iconsax.location,
              title: request['landmark'],
              subtitle: "Nearby Landmark",
            ),

          // 🔐 VERIFICATION CODE
          if (status == 'accepted' && request['verificationCode'] != null)
            _VerificationCode(controller: controller, code: request['verificationCode']),
          if (status == 'accepted' && request['verificationCode'] != null)
            SizedBox(height: 14.h),

          SizedBox(height: 18.h),

          // 🎬 ACTION BUTTONS
          if (status == 'mechanic_accepted')
            _MechanicAcceptedMessage()
          else if (status == 'accepted') 
            _ActionButtons(controller: controller, request: request)
          else if (status == 'verified')
            _VerifiedMessage()
          else
            _WaitingMessage(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? status;
  const _Header({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Active Request",
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
          ),
          _StatusChip(status: status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String? status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'mechanic_accepted':
        color = AppColors.warning;
        text = "Approval Needed";
        break;
      case 'accepted':
        color = AppColors.success;
        text = "Accepted";
        break;
      case 'verified':
        color = AppColors.primary;
        text = "In Progress";
        break;
      case 'open':
        color = AppColors.secondary;
        text = "Waiting";
        break;
      case 'completed':
        color = AppColors.info;
        text = "Completed";
        break;
      default:
        color = AppColors.disabled;
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
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final ActiveRequestCardController controller;
  final Map<String, dynamic> request;

  const _MapPreview({required this.controller, required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => LiveTrackingView(requestId: request['id']));
      },
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            children: [
              Obx(() => controller.mechanicLat.value != null && controller.mechanicLng.value != null
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(controller.mechanicLat.value!, controller.mechanicLng.value!),
                        zoom: 14,
                      ),
                      markers: controller.markers,
                      onMapCreated: controller.setMapController,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      mapToolbarEnabled: false,
                    )
                  : Container(
                      color: AppColors.background,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(height: 12.h),
                            Text(
                              "Loading mechanic location...",
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    )),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.mouse_circle, size: 14.w, color: AppColors.surface),
                      SizedBox(width: 4.w),
                      Text(
                        "Tap to view",
                        style: AppTextStyles.label.copyWith(color: AppColors.surface),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() => controller.mechanicLat.value != null && controller.mechanicLng.value != null
                  ? Positioned(
                      left: 12.w,
                      bottom: 12.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                          ],
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
                            SizedBox(width: 6.w),
                            Text(
                              "MECHANIC EN ROUTE",
                              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary, fontSize: 10.sp),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCode extends StatefulWidget {
  final ActiveRequestCardController controller;
  final String code;

  const _VerificationCode({required this.controller, required this.code});

  @override
  State<_VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<_VerificationCode> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Iconsax.verify, color: AppColors.primary, size: 20.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Verification Code",
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "Share this code with the mechanic to confirm job completion",
            style: AppTextStyles.caption,
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.code.split('').map((digit) {
              return Flexible(
                child: Container(
                  width: 40.w,
                  height: 48.h,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isRevealed ? digit : "•",
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _isRevealed = !_isRevealed);
                  },
                  icon: Icon(
                    _isRevealed ? Iconsax.eye_slash : Iconsax.eye,
                    size: 16.w,
                  ),
                  label: Text(
                    _isRevealed ? "Hide" : "View Code",
                    style: AppTextStyles.button.copyWith(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.controller.shareVerificationCode(widget.code),
                  icon: Icon(Iconsax.share, size: 16.w),
                  label: Text("Share", style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
}

class _ActionButtons extends StatelessWidget {
  final ActiveRequestCardController controller;
  final Map<String, dynamic> request;

  const _ActionButtons({required this.controller, required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: controller.callMechanic,
                  icon: Icon(Iconsax.call, size: 18.w, color: AppColors.surface),
                  label: Text("Call", style: AppTextStyles.button.copyWith(color: AppColors.surface)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
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
                  onPressed: controller.openChat,
                  icon: Icon(Iconsax.message, size: 18.w, color: AppColors.surface),
                  label: Text("Chat", style: AppTextStyles.button.copyWith(color: AppColors.surface)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
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
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.to(() => LiveTrackingView(requestId: request['id']));
            },
            icon: Icon(Iconsax.location_cross, size: 18.w, color: AppColors.primary),
            label: Text("Track Mechanic Live", style: AppTextStyles.button.copyWith(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitingMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.clock, color: AppColors.secondaryDark),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "Waiting for a mechanic to accept your request...",
              style: AppTextStyles.body2.copyWith(color: AppColors.secondaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Iconsax.setting_2, color: AppColors.primary, size: 36.w),
          SizedBox(height: 12.h),
          Text(
            "Mechanic is working on your vehicle",
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            "Please wait securely. Your mechanic is diagnosing and fixing the issue.",
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MechanicAcceptedMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.08),
            AppColors.success.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.verify, color: AppColors.success, size: 32.w),
          ),
          SizedBox(height: 12.h),
          Text(
            "A Mechanic Has Accepted!",
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            "Do you want this mechanic to help you? Accept to generate a verification code.",
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Decline Mechanic?",
                        middleText: "This will open your request to other mechanics.",
                        textConfirm: "Yes, Decline",
                        textCancel: "No",
                        confirmTextColor: AppColors.surface,
                        buttonColor: AppColors.error,
                        onConfirm: () {
                          Get.back();
                          controller.declineMechanic();
                        },
                      );
                    },
                    icon: Icon(Iconsax.close_circle, size: 18.w),
                    label: Text("Decline", style: AppTextStyles.button.copyWith(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.approveMechanic(),
                    icon: Icon(Iconsax.tick_circle, size: 18.w, color: AppColors.surface),
                    label: Text("Accept", style: AppTextStyles.button.copyWith(color: AppColors.surface)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MechanicInfoTile extends StatelessWidget {
  final String mechanicId;
  final String mechanicName;

  const _MechanicInfoTile({required this.mechanicId, required this.mechanicName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: FirebaseFirestore.instance.collection('users').doc(mechanicId).get(),
      builder: (context, snapshot) {
        double rating = 0.0;
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          rating = (data['averageRating'] ?? 0.0).toDouble();
        }

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.user, color: AppColors.primary, size: 20.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mechanicName,
                      style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "Assigned Mechanic",
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                        ),
                        if (rating > 0) ...[
                          SizedBox(width: 8.w),
                          Icon(Iconsax.star1, color: AppColors.warning, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/mechanic_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';
import 'package:driveresq_app/utils/helpers/app_dialogs.dart';

class ActiveRequestDetailsPage extends StatelessWidget {
  static const primary = Color(0xFF6C63FF);

  const ActiveRequestDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MechanicController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Active Request",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!controller.hasActiveJob.value ||
            controller.activeJob.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.clipboard,
                  size: 80.w,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16.h),
                Text(
                  "No Active Request",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final job = controller.activeJob.value!;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Status Header
              _buildStatusHeader(job),

              SizedBox(height: 20.h),

              // Main Content Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Distance Badge
                    if (job['distance'] != null) _buildDistanceBadge(job),

                    SizedBox(height: 20.h),

                    // Location Section
                    _buildLocationSection(job),

                    SizedBox(height: 16.h),

                    // Divider
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Divider(color: Colors.grey.shade200, thickness: 1),
                    ),

                    SizedBox(height: 16.h),

                    // Vehicle Type
                    _buildDetailRow(
                      icon: Iconsax.car,
                      label: "Vehicle Type",
                      value: job['vehicleType'] ?? 'Not specified',
                      color: Colors.blue,
                    ),

                    SizedBox(height: 12.h),

                    // Description (if available)
                    if (job['description'] != null &&
                        job['description'].toString().isNotEmpty) ...[
                      _buildDescriptionSection(job['description']),
                      SizedBox(height: 12.h),
                    ],

                    // Problem Section
                    _buildProblemSection(job),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Action Buttons
              _buildActionButtons(context, job, controller),

              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(Map<String, dynamic> job) {
    bool isWaiting = job['status'] == 'mechanic_accepted';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWaiting
              ? [Colors.orange.shade400, Colors.orange.shade600]
              : [Colors.green.shade400, Colors.green.shade600],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWaiting ? Iconsax.clock : Iconsax.setting_2,
              color: Colors.white,
              size: 32.w,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            isWaiting ? "WAITING FOR APPROVAL" : "MISSION IN PROGRESS",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isWaiting ? "PENDING" : "ACTIVE",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBadge(Map<String, dynamic> job) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.blue.shade700],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.location, color: Colors.white, size: 24.w),
            SizedBox(width: 10.w),
            Text(
              "${job['distance']} km",
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              "away",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Map<String, dynamic> job) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Iconsax.location, color: primary, size: 24.w),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Driver Location",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job['locationName'] ?? 'Location not available',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (job['landmark'] != null &&
                job['landmark'].toString().isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 18.w,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        job['landmark'],
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.w, color: color),
            SizedBox(width: 12.w),
            Text(
              "$label: ",
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.document_text,
                  color: Colors.blue.shade700,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Additional Information",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemSection(Map<String, dynamic> job) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade50, Colors.red.shade100],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.shade200, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade200,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Iconsax.warning_2, color: Colors.red, size: 24.w),
                ),
                SizedBox(width: 12.w),
                Text(
                  "PROBLEM REPORTED",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              job['problem'] ?? 'No problem specified',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Map<String, dynamic> job,
    MechanicController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          if (job['status'] == 'mechanic_accepted') ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: Colors.orange.shade700,
                    size: 28.w,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Waiting for Driver",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "The driver has been notified of your offer. The job will officially start once they approve.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.orange.shade700,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(controller),
                icon: Icon(Iconsax.close_square, size: 20.w),
                label: Text(
                  "Cancel Offer",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),
          ] else ...[
            // Primary Actions
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Iconsax.call,
                    label: "Call Driver",
                    color: primary,
                    onPressed: () => _callDriver(job),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _actionButton(
                    icon: Iconsax.location,
                    label: "Navigate",
                    color: Colors.blue,
                    onPressed: () => _navigateToDriver(job),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Secondary Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(controller),
                    icon: Icon(Iconsax.close_square, size: 20.w),
                    label: Text(
                      "Cancel Job",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCompleteDialog(controller),
                    icon: Icon(Iconsax.tick_circle, size: 20.w),
                    label: Text(
                      "Complete",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20.w),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        elevation: 2,
      ),
    );
  }

  // 📞 Call Driver
  void _callDriver(Map<String, dynamic> job) async {
    final phone = job['driverPhone'];
    if (phone != null) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        AppSnackbar.error('Cannot make call');
      }
    } else {
      AppSnackbar.error('Phone number not available');
    }
  }

  // 🗺 Navigate to Driver
  void _navigateToDriver(Map<String, dynamic> job) async {
    final lat = job['driverLat'];
    final lng = job['driverLng'];

    if (lat != null && lng != null) {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppSnackbar.error('Cannot open maps');
      }
    } else {
      AppSnackbar.error('Location not available');
    }
  }

  // ❌ Show Cancel Dialog
  void _showCancelDialog(MechanicController controller) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Cancel Job',
      message: 'Are you sure you want to cancel this job?',
      confirmText: 'Yes, Cancel',
      cancelText: 'No',
      isDangerous: true,
    );
    if (confirmed == true) {
      controller.cancelActiveJob();
      Get.back();
    }
  }

  // ✅ Navigate to Job Completion Flow
  void _showCompleteDialog(MechanicController controller) async {
    if (controller.activeJob.value == null) return;

    final confirmed = await AppDialogs.confirm(
      title: 'Complete Job',
      message:
          "Ready to complete this job? You'll fill in a summary, confirm cash collection, and rate the customer.",
      confirmText: 'Yes, Proceed',
      cancelText: 'Not Yet',
    );
    if (confirmed == true) {
      Get.toNamed(
        '/job-completion',
        arguments: {
          'job': controller.activeJob.value!,
          'jobId': controller.activeJob.value!['id'],
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../chat/controllers/chat_controller.dart';
import '../../../chat/views/chat_screen.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class MechanicActiveJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isActive;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  MechanicActiveJobCard({
    super.key,
    required this.job,
    this.isActive = false,
    this.onAccept,
    this.onCancel,
  });

  static const primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          _buildHeader(),

          // Main Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance Badge (Most Important)
                if (job['distance'] != null) _buildDistanceBadge(),

                if (job['distance'] != null) SizedBox(height: 16.h),

                // Location Info (Single, Clean Display)
                _buildLocationCard(),

                SizedBox(height: 12.h),

                // Additional Details
                _buildDetailsSection(),

                SizedBox(height: 16.h),

                // Problem Card (Highlighted)
                _buildProblemCard(),

                SizedBox(height: 16.h),

                // Action Buttons
                isActive
                    ? _buildActiveJobButtons()
                    : _buildOpenRequestButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.build_circle : Icons.new_releases,
                color: Colors.white,
                size: 22.w,
              ),
              SizedBox(width: 8.w),
              Text(
                isActive ? "ACTIVE REQUEST" : "NEW REQUEST",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isActive ? "IN PROGRESS" : "AWAITING",
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade500, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me, color: Colors.white, size: 20.w),
          SizedBox(width: 8.w),
          Text(
            "${job['distance']} km away",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.location_on, color: primary, size: 20.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Driver Location",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      job['locationName'] ?? 'Location not available',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
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
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.place, size: 16.w, color: Colors.grey.shade600),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      job['landmark'],
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
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
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.directions_car_rounded,
          "Vehicle Type",
          job['vehicleType'] ?? 'Not specified',
        ),
        if (job['description'] != null &&
            job['description'].toString().isNotEmpty) ...[
          SizedBox(height: 10.h),
          _buildDescriptionCard(),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: Colors.grey.shade700),
          SizedBox(width: 10.w),
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
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_rounded, color: Colors.blue.shade700, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Additional Info",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  job['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.red.shade200,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.warning_rounded, color: Colors.red, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PROBLEM REPORTED",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  job['problem'] ?? 'No problem specified',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Buttons for ACTIVE job
  Widget _buildActiveJobButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.phone,
                label: "Call",
                color: primary,
                onPressed: _callDriver,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _actionButton(
                icon: Icons.chat_bubble,
                label: "Chat",
                color: Color(0xFF6C63FF),
                onPressed: _openChat,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _actionButton(
                icon: Icons.navigation,
                label: "Navigate",
                color: Colors.blue,
                onPressed: _navigateToDriver,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: Icon(Icons.cancel_outlined),
                label: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _completeJob,
                icon: Icon(Icons.check_circle),
                label: Text(
                  "Complete",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Buttons for OPEN request
  Widget _buildOpenRequestButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAccept,
        icon: Icon(Icons.check_circle_outline, size: 22.w),
        label: Text(
          "Accept Request",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          elevation: 2,
        ),
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
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        elevation: 2,
      ),
    );
  }

  // 📞 Call Driver
  void _callDriver() async {
    final phone = job['driverPhone'];
    if (phone != null) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar("Error", "Cannot make call");
      }
    } else {
      Get.snackbar("Error", "Phone number not available");
    }
  }

  // 🗺 Navigate to Driver
  void _navigateToDriver() async {
    final lat = job['driverLat'];
    final lng = job['driverLng'];

    if (lat != null && lng != null) {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Error", "Cannot open maps");
      }
    } else {
      Get.snackbar("Error", "Location not available");
    }
  }

  // ✅ Navigate to Job Completion Flow
  void _completeJob() {
    Get.defaultDialog(
      title: "Complete Job",
      middleText:
          "Ready to complete? You'll fill in a summary, collect payment, and rate the customer.",
      textConfirm: "Yes, Proceed",
      textCancel: "Not Yet",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        Get.toNamed(
          '/job-completion',
          arguments: {'job': job, 'jobId': job['id']},
        );
      },
    );
  }

  // 💬 Open Chat with Driver
  void _openChat() {
    final chatId = job['id'] ?? '';
    if (chatId.isEmpty) {
      Get.snackbar('Error', 'Chat not available');
      return;
    }

    Get.delete<ChatController>(force: true);
    Get.put(
      ChatController(
        chatId: chatId,
        otherUserName: job['driverName'] ?? 'Driver',
        otherUserPhoto: job['driverPhoto'] ?? '',
        myRole: 'mechanic',
      ),
    );
    Get.to(
      () => ChatScreen(),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 250),
    );
  }
}

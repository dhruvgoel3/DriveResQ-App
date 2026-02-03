import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/mechanic_controller.dart';

class ActiveRequestDetailsPage extends StatelessWidget {
  const ActiveRequestDetailsPage({super.key});

  static const primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MechanicController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Active Request",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!controller.hasActiveJob.value || controller.activeJob.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  "No Active Request",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
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
              _buildStatusHeader(),

              const SizedBox(height: 20),

              // Main Content Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Distance Badge
                    if (job['distance'] != null) _buildDistanceBadge(job),

                    const SizedBox(height: 20),

                    // Location Section
                    _buildLocationSection(job),

                    const SizedBox(height: 16),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.grey.shade200, thickness: 1),
                    ),

                    const SizedBox(height: 16),

                    // Vehicle Type
                    _buildDetailRow(
                      icon: Icons.directions_car_rounded,
                      label: "Vehicle Type",
                      value: job['vehicleType'] ?? 'Not specified',
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    // Description (if available)
                    if (job['description'] != null &&
                        job['description'].toString().isNotEmpty) ...[
                      _buildDescriptionSection(job['description']),
                      const SizedBox(height: 12),
                    ],

                    // Problem Section
                    _buildProblemSection(job),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(context, job, controller),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.build_circle,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "MISSION IN PROGRESS",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "ACTIVE",
              style: GoogleFonts.poppins(
                fontSize: 11,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.blue.shade700],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.near_me, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              "${job['distance']} km",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "away",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Map<String, dynamic> job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Driver Location",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['locationName'] ?? 'Location not available',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (job['landmark'] != null && job['landmark'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job['landmark'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Text(
              "$label: ",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_rounded, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Additional Information",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade50, Colors.red.shade100],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_rounded, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  "PROBLEM REPORTED",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job['problem'] ?? 'No problem specified',
              style: GoogleFonts.poppins(
                fontSize: 15,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Primary Actions
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.phone_rounded,
                  label: "Call Driver",
                  color: primary,
                  onPressed: () => _callDriver(job),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.navigation_rounded,
                  label: "Navigate",
                  color: Colors.blue,
                  onPressed: () => _navigateToDriver(job),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Secondary Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(controller),
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: Text(
                    "Cancel Job",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteDialog(controller),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    "Complete",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
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
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
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
        Get.snackbar("Error", "Cannot make call");
      }
    } else {
      Get.snackbar("Error", "Phone number not available");
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
        Get.snackbar("Error", "Cannot open maps");
      }
    } else {
      Get.snackbar("Error", "Location not available");
    }
  }

  // ❌ Show Cancel Dialog
  void _showCancelDialog(MechanicController controller) {
    Get.defaultDialog(
      title: "Cancel Job",
      middleText: "Are you sure you want to cancel this job?",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.cancelActiveJob();
        Get.back(); // Go back to main page
      },
    );
  }

  // ✅ Show Complete Dialog
  void _showCompleteDialog(MechanicController controller) {
    Get.defaultDialog(
      title: "Complete Job",
      middleText: "Mark this job as completed?",
      textConfirm: "Yes, Complete",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.completeJob();
        Get.back(); // Go back to main page
      },
    );
  }
}
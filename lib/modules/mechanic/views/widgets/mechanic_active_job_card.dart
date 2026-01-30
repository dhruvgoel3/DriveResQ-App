import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../controller/mechanic_controller.dart';

class MechanicActiveJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isActive;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  const MechanicActiveJobCard({
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),

          // 🗺 Distance & Location
          _locationInfo(),

          const SizedBox(height: 12),

          // 🚗 Vehicle Type
          _infoRow(Icons.directions_car, "Vehicle", job['vehicleType'] ?? 'N/A'),

          const SizedBox(height: 8),

          // 📍 Location Name
          _infoRow(Icons.location_on, "Location", job['locationName'] ?? 'N/A'),

          const SizedBox(height: 8),

          // 🏠 Landmark
          if (job['landmark'] != null && job['landmark'].toString().isNotEmpty)
            _infoRow(Icons.place, "Landmark", job['landmark']),

          if (job['landmark'] != null && job['landmark'].toString().isNotEmpty)
            const SizedBox(height: 8),

          // 📝 Description
          if (job['description'] != null && job['description'].toString().isNotEmpty)
            _descriptionCard(job['description']),

          if (job['description'] != null && job['description'].toString().isNotEmpty)
            const SizedBox(height: 12),

          // ⚠️ Problem
          _problemCard(job['problem'] ?? 'No problem specified'),

          const SizedBox(height: 14),

          // 🔘 Action Buttons
          isActive ? _activeJobButtons() : _openRequestButtons(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isActive ? "MISSION DETAILS" : "NEW REQUEST",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Row(
          children: [
            if (job['distance'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${job['distance']} km",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.12)
                    : Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? "IN PROGRESS" : "OPEN",
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _locationInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              job['locationName'] ?? 'Location not available',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _descriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _problemCard(String problem) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              problem,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Buttons for ACTIVE job
  Widget _activeJobButtons() {
    return Column(
      children: [
        Row(
          children: [
            _outlineButton(Icons.call, "Call Driver", _callDriver),
            const SizedBox(width: 12),
            _primaryButton(Icons.navigation, "Navigate", _navigateToDriver),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Cancel Job"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _completeJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Complete Job"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Buttons for OPEN request
  Widget _openRequestButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAccept,
        icon: const Icon(Icons.check_circle),
        label: const Text("Accept Request"),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _primaryButton(IconData icon, String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _outlineButton(IconData icon, String text, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
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

  // ✅ Complete Job
  void _completeJob() {
    Get.defaultDialog(
      title: "Complete Job",
      middleText: "Mark this job as completed?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.find<MechanicController>().completeJob();
      },
    );
  }
}
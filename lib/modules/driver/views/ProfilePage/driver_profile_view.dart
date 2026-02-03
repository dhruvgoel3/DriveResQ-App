import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/driver_profile_controller.dart';

class DriverProfileView extends StatelessWidget {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                controller.isEditMode.value ? Icons.close : Icons.edit,
                color: controller.isEditMode.value
                    ? Colors.red
                    : const Color(0xFF6C63FF),
              ),
              onPressed: controller.toggleEditMode,
            );
          }),
        ],
      ),
      body: Obx(() {
        final data = controller.userData.value;
        if (data == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C63FF),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _profileHeader(data),
              const SizedBox(height: 20),
              _basicInfoCard(controller, data),
              const SizedBox(height: 16),
              _safetyTrustCard(),
              const SizedBox(height: 16),
              _statisticsCard(),
              const SizedBox(height: 24),
              _logoutButton(controller),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  // 🔝 PROFILE HEADER
  Widget _profileHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6C63FF),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: data['photoUrl'] != null &&
                      data['photoUrl'].toString().isNotEmpty
                      ? NetworkImage(data['photoUrl'])
                      : null,
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                  child: data['photoUrl'] == null ||
                      data['photoUrl'].toString().isEmpty
                      ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF6C63FF),
                  )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF6C63FF),
                    child: Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data['name'] ?? "Driver Name",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data['phone'] ?? "",
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  "VERIFIED DRIVER",
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📄 BASIC INFO (EDITABLE)
  Widget _basicInfoCard(
      DriverProfileController controller,
      Map<String, dynamic> data,
      ) {
    return _card(
      title: "BASIC INFORMATION",
      child: Obx(() {
        final isEdit = controller.isEditMode.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            isEdit
                ? _editField(
              label: "Full Name",
              controller: controller.nameController,
              icon: Icons.person,
            )
                : _infoRow(
              Icons.person,
              "Full Name",
              data['name'] ?? "Not set",
            ),

            const SizedBox(height: 12),

            isEdit
                ? _editField(
              label: "Vehicle Type",
              controller: controller.vehicleTypeController,
              icon: Icons.directions_car,
            )
                : _infoRow(
              Icons.directions_car,
              "Vehicle Type",
              data['vehicleType'] ?? "Not added",
            ),

            const SizedBox(height: 12),

            isEdit
                ? _editField(
              label: "Plate Number",
              controller: controller.plateNumberController,
              icon: Icons.confirmation_number,
            )
                : _infoRow(
              Icons.confirmation_number,
              "Plate Number",
              data['plateNumber'] ?? "Not added",
            ),

            if (isEdit) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveBasicInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // 🛡 SAFETY & TRUST
  Widget _safetyTrustCard() {
    return _card(
      title: "SAFETY & TRUST",
      child: Column(
        children: [
          const SizedBox(height: 12),
          _statusRow("Phone Verified", true, Icons.phone_android),
          const Divider(height: 24),
          _statusRow("Location Access", true, Icons.location_on),
        ],
      ),
    );
  }

  // 📊 STATISTICS CARD (NEW)
  Widget _statisticsCard() {
    return _card(
      title: "STATISTICS",
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.notifications_active,
                  label: "Requests",
                  value: "0",
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statItem(
                  icon: Icons.check_circle,
                  label: "Completed",
                  value: "0",
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 🚪 LOGOUT BUTTON (IMPROVED)
  Widget _logoutButton(DriverProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          "Logout",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // 🔁 CARD WRAPPER
  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          child,
        ],
      ),
    );
  }

  // ✏️ EDIT FIELD
  Widget _editField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ℹ️ INFO ROW
  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ STATUS ROW
  Widget _statusRow(String title, bool verified, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: verified
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            verified ? Icons.check_circle : Icons.cancel,
            color: verified ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                verified ? "Active" : "Inactive",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          icon,
          color: Colors.grey.shade400,
          size: 20,
        ),
      ],
    );
  }
}
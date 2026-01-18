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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          "Driver Profile",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                controller.isEditMode.value ? Icons.close : Icons.edit,
                color: Colors.black,
              ),
              onPressed: controller.toggleEditMode,
            );
          }),
        ],
      ),
      body: Obx(() {
        final data = controller.userData.value;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _profileHeader(data),
              const SizedBox(height: 16),
              _basicInfoCard(controller, data),
              const SizedBox(height: 16),
              _safetyTrustCard(),
              const SizedBox(height: 24),
              _logoutButton(controller),
            ],
          ),
        );
      }),
    );
  }

  // 🔝 PROFILE HEADER
  Widget _profileHeader(Map<String, dynamic> data) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundImage:
                  data['photoUrl'] != null &&
                      data['photoUrl'].toString().isNotEmpty
                  ? NetworkImage(data['photoUrl'])
                  : null,
              backgroundColor: Colors.grey.shade200,
              child:
                  data['photoUrl'] == null ||
                      data['photoUrl'].toString().isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF6C63FF),
                child: Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          data['name'] ?? "John Doe",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          data['phone'] ?? "",
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          "✔ VERIFIED DRIVER",
          style: GoogleFonts.poppins(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 📄 BASIC INFO (EDITABLE)
  Widget _basicInfoCard(
    DriverProfileController controller,
    Map<String, dynamic> data,
  ) {
    return _card(
      child: Obx(() {
        final isEdit = controller.isEditMode.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BASIC INFORMATION",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            isEdit
                ? _editField(
                    label: "Full Name",
                    controller: controller.nameController,
                  )
                : _infoRow(
                    Icons.person,
                    "Full Name",
                    data['name'] ?? "Not set",
                  ),

            isEdit
                ? _editField(
                    label: "Vehicle Type",
                    controller: controller.vehicleTypeController,
                  )
                : _infoRow(
                    Icons.directions_car,
                    "Vehicle Type",
                    data['vehicleType'] ?? "Not added",
                  ),

            isEdit
                ? _editField(
                    label: "Plate Number",
                    controller: controller.plateNumberController,
                  )
                : _infoRow(
                    Icons.confirmation_number,
                    "Plate Number",
                    data['plateNumber'] ?? "Not added",
                  ),

            if (isEdit) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveBasicInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SAFETY & TRUST",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const _StatusRow("Phone Verified", true),
          const _StatusRow("Location Access", true),
        ],
      ),
    );
  }

  // 🚪 LOGOUT
  Widget _logoutButton(DriverProfileController controller) {
    return OutlinedButton.icon(
      onPressed: controller.logout,
      icon: const Icon(Icons.logout, color: Colors.red),
      label: Text(
        "Logout",
        style: GoogleFonts.poppins(
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // 🔁 CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }

  // ✏️ EDIT FIELD
  Widget _editField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ℹ️ INFO ROW
  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
            child: Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String title;
  final bool verified;

  const _StatusRow(this.title, this.verified);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        verified ? Icons.check_circle : Icons.cancel,
        color: verified ? Colors.green : Colors.red,
      ),
      title: Text(title, style: GoogleFonts.poppins()),
    );
  }
}

// driver profile view

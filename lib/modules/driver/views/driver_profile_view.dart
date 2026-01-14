import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_profile_controller.dart';

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
        title: const Text(
          "Driver Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => _openEditProfile(controller),
          ),
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
              _profileCompletion(),
              const SizedBox(height: 16),
              _basicInfoCard(data),
              const SizedBox(height: 16),
              _safetyTrustCard(),
              const SizedBox(height: 16),
              _settingsTile(Icons.notifications, "Notifications"),
              _settingsTile(Icons.language, "Language", trailing: "English"),
              const SizedBox(height: 20),
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
              backgroundImage: data['photoUrl'] != null &&
                  data['photoUrl'].toString().isNotEmpty
                  ? NetworkImage(data['photoUrl'])
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: data['photoUrl'] == null ||
                  data['photoUrl'].toString().isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          data['name'] ?? "John Doe",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          data['phone'] ?? "",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        const Text(
          "✔ VERIFIED DRIVER",
          style: TextStyle(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 📊 PROFILE COMPLETION
  Widget _profileCompletion() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Profile Completion",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text("80%",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.8,
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            "Almost there! Complete your profile to unlock all features.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 📄 BASIC INFO
  Widget _basicInfoCard(Map<String, dynamic> data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("BASIC INFORMATION",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _infoRow(Icons.person, "Full Name", data['name'] ?? "Not set"),
          _infoRow(Icons.directions_car, "Vehicle Type", "Not added"),
          _infoRow(Icons.confirmation_number, "Plate Number", "Not added"),
        ],
      ),
    );
  }

  // 🛡 SAFETY & TRUST
  Widget _safetyTrustCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("SAFETY & TRUST",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _statusRow("Phone Verified", true),
          _statusRow("Location Access", true),
        ],
      ),
    );
  }

  // ⚙ SETTINGS TILE
  Widget _settingsTile(IconData icon, String title, {String? trailing}) {
    return _card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing != null
            ? Text(trailing, style: TextStyle(color: Colors.grey.shade600))
            : const Icon(Icons.chevron_right),
      ),
    );
  }

  // 🚪 LOGOUT
  Widget _logoutButton(DriverProfileController controller) {
    return OutlinedButton.icon(
      onPressed: controller.logout,
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text(
        "Logout",
        style: TextStyle(color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // 🔁 REUSABLE CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  // 🔹 INFO ROW
  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(value,
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _openEditProfile(DriverProfileController controller) {
    // You already implemented edit profile logic earlier
    // Just reuse that bottom sheet here
  }
}

class _statusRow extends StatelessWidget {
  final String title;
  final bool verified;

  const _statusRow(this.title, this.verified);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        verified ? Icons.check_circle : Icons.cancel,
        color: verified ? Colors.green : Colors.red,
      ),
      title: Text(title),
    );
  }
}

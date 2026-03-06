import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/driver_profile_controller.dart';

class DriverProfileView extends StatelessWidget {
  const DriverProfileView({super.key});

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DriverProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        if (c.userData.value == null) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        return CustomScrollView(
          slivers: [
            _buildHeader(c),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _statsRow(c),
                  const SizedBox(height: 16),
                  _personalInfoCard(c),
                  const SizedBox(height: 16),
                  _identityCard(c),
                  const SizedBox(height: 16),
                  _safetyCard(c),
                  const SizedBox(height: 24),
                  _logoutButton(c),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─── Gradient header ───
  Widget _buildHeader(DriverProfileController c) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _accent,
      automaticallyImplyLeading: false,
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              c.isEditMode.value ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: c.toggleEditMode,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF8B7CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white24,
                    child: Text(
                      c.displayName.isNotEmpty
                          ? c.displayName[0].toUpperCase()
                          : 'D',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  c.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c.phone,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        c.isOnboarded ? Icons.verified : Icons.pending,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        c.isOnboarded ? 'VERIFIED DRIVER' : 'SETUP PENDING',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Stats row ───
  Widget _statsRow(DriverProfileController c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem(
            'Requests',
            c.totalRequests.value.toString(),
            Icons.send,
            Colors.blue,
          ),
          _divider(),
          _statItem(
            'Completed',
            c.completedRequests.value.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _divider(),
          _statItem(
            'Spent',
            '₹${c.totalSpent.value.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  // ─── Personal Info (editable) ───
  Widget _personalInfoCard(DriverProfileController c) {
    return _card(
      title: 'PERSONAL INFORMATION',
      icon: Icons.person,
      child: Obx(() {
        final edit = c.isEditMode.value;
        return Column(
          children: [
            if (edit) ...[
              _editField('Full Name', c.nameController, Icons.person),
              const SizedBox(height: 12),
              _editField('Email', c.emailController, Icons.email),
              const SizedBox(height: 12),
              _editField(
                'Address',
                c.addressController,
                Icons.home,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: c.isLoading.value ? null : c.saveBasicInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: c.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ] else ...[
              _infoRow(Icons.person, 'Full Name', c.displayName),
              _sep(),
              _infoRow(Icons.phone, 'Phone', c.phone),
              if (c.email.isNotEmpty) ...[
                _sep(),
                _infoRow(Icons.email, 'Email', c.email),
              ],
              if (c.address.isNotEmpty) ...[
                _sep(),
                _infoRow(Icons.home, 'Address', c.address),
              ],
              if (c.gender.isNotEmpty) ...[
                _sep(),
                _infoRow(Icons.wc, 'Gender', c.gender),
              ],
              if (c.dob.isNotEmpty) ...[
                _sep(),
                _infoRow(Icons.cake, 'Date of Birth', c.dob),
              ],
            ],
          ],
        );
      }),
    );
  }

  // ─── Identity Card ───
  Widget _identityCard(DriverProfileController c) {
    if (c.govtIdType.isEmpty) {
      return const SizedBox.shrink();
    }

    return _card(
      title: 'IDENTITY VERIFICATION',
      icon: Icons.verified_user,
      child: Column(
        children: [
          _infoRow(Icons.credit_card, 'ID Type', c.govtIdType),
          _sep(),
          _infoRow(Icons.numbers, 'ID Number', c.govtIdNumber),
          _sep(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ID Verified',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Safety card ───
  Widget _safetyCard(DriverProfileController c) {
    return _card(
      title: 'SAFETY & TRUST',
      icon: Icons.shield,
      child: Column(
        children: [
          _statusRow('Phone Verified', true, Icons.phone_android),
          _sep(),
          _statusRow('Location Access', true, Icons.location_on),
          _sep(),
          _statusRow('identity Verified', c.isOnboarded, Icons.badge),
        ],
      ),
    );
  }

  // ─── Reusable widgets ───
  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _accent),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, bool active, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (active ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              active ? Icons.check_circle : Icons.cancel,
              size: 20,
              color: active ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            active ? 'Active' : 'Pending',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: active ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() =>
      Divider(height: 16, thickness: 0.5, color: Colors.grey.shade200);

  Widget _editField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: _accent),
        filled: false,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
      ),
    );
  }

  Widget _logoutButton(DriverProfileController c) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: c.logout,
        icon: const Icon(Icons.logout),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

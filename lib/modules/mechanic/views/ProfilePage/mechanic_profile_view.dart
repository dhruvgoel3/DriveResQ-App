import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/mechanic_profile_controller.dart';

class MechanicProfileView extends StatelessWidget {
  const MechanicProfileView({super.key});

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MechanicProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Obx(() {
        final data = c.userData.value;
        if (data == null) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        return CustomScrollView(
          slivers: [
            // Gradient AppBar with profile
            _sliverHeader(c, data),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _statsRow(c),
                  const SizedBox(height: 16),
                  _personalInfoCard(c, data),
                  const SizedBox(height: 14),
                  _shopInfoCard(c, data),
                  const SizedBox(height: 14),
                  _specializationsCard(c),
                  const SizedBox(height: 14),
                  _availabilityCard(c, data),
                  const SizedBox(height: 14),
                  _pricingCard(c, data),
                  const SizedBox(height: 14),
                  _verificationCard(c, data),
                  const SizedBox(height: 20),
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

  // ─────────────────────── SLIVER HEADER ───────────────────────
  Widget _sliverHeader(MechanicProfileController c, Map<String, dynamic> data) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _accent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              c.isEditMode.value ? Icons.close : Icons.edit_outlined,
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
              colors: [Color(0xFF6C63FF), Color(0xFF5A52E8), Color(0xFF4840D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundImage: _profileImage(data),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: _profileImage(data) == null
                        ? const Icon(
                            Icons.person,
                            size: 46,
                            color: Colors.white70,
                          )
                        : null,
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
                const SizedBox(height: 2),
                if (data['shopName'] != null &&
                    data['shopName'].toString().isNotEmpty)
                  Text(
                    data['shopName'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(height: 8),
                // Verification Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.verificationColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: c.verificationColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        c.verificationColor == const Color(0xFF4CAF50)
                            ? Icons.verified
                            : Icons.pending,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        c.verificationBadge,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
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

  ImageProvider? _profileImage(Map<String, dynamic> data) {
    final url = data['profilePhotoUrl'] ?? data['photoUrl'];
    if (url != null && url.toString().isNotEmpty) {
      return NetworkImage(url);
    }
    return null;
  }

  // ─────────────────────── STATS ROW ───────────────────────
  Widget _statsRow(MechanicProfileController c) {
    return Obx(
      () => Row(
        children: [
          _statTile(
            Icons.check_circle,
            'Jobs',
            c.totalJobsCompleted.value.toString(),
            Colors.green,
          ),
          const SizedBox(width: 10),
          _statTile(
            Icons.star_rounded,
            'Rating',
            c.rating.value > 0 ? c.rating.value.toStringAsFixed(1) : '—',
            Colors.amber,
          ),
          const SizedBox(width: 10),
          _statTile(
            Icons.account_balance_wallet,
            'Earned',
            '₹${c.totalEarnings.value.toStringAsFixed(0)}',
            _accent,
          ),
          const SizedBox(width: 10),
          _statTile(
            Icons.bolt,
            'Active',
            c.activeJobs.value.toString(),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── PERSONAL INFO ───────────────────────
  Widget _personalInfoCard(
    MechanicProfileController c,
    Map<String, dynamic> data,
  ) {
    return Obx(() {
      final isEdit = c.isEditMode.value;
      return _card(
        icon: Icons.person_outline,
        title: 'Personal Information',
        child: Column(
          children: [
            isEdit
                ? _editField('Full Name', c.nameController, Icons.badge)
                : _infoRow(Icons.badge, 'Full Name', c.displayName),
            const Divider(height: 20),
            _infoRow(Icons.phone, 'Phone', data['phone'] ?? '—'),
            const Divider(height: 20),
            isEdit
                ? _editField('Email', c.emailController, Icons.email)
                : _infoRow(
                    Icons.email_outlined,
                    'Email',
                    data['email'] ?? 'Not added',
                  ),
            const Divider(height: 20),
            _infoRow(
              Icons.cake_outlined,
              'Date of Birth',
              _formatDob(data['dob']),
            ),
            const Divider(height: 20),
            _infoRow(Icons.person, 'Gender', data['gender'] ?? '—'),
            if (isEdit) ...[const SizedBox(height: 16), _saveButton(c)],
          ],
        ),
      );
    });
  }

  // ─────────────────────── SHOP INFO ───────────────────────
  Widget _shopInfoCard(MechanicProfileController c, Map<String, dynamic> data) {
    return Obx(() {
      final isEdit = c.isEditMode.value;
      return _card(
        icon: Icons.store_outlined,
        title: 'Shop / Garage',
        child: Column(
          children: [
            isEdit
                ? _editField(
                    'Shop Name',
                    c.shopNameController,
                    Icons.storefront,
                  )
                : _infoRow(
                    Icons.storefront,
                    'Shop Name',
                    data['shopName'] ?? '—',
                  ),
            const Divider(height: 20),
            isEdit
                ? _editField(
                    'Address',
                    c.shopAddressController,
                    Icons.location_on,
                  )
                : _infoRow(
                    Icons.location_on_outlined,
                    'Address',
                    data['shopAddress'] ?? 'Not added',
                  ),
            const Divider(height: 20),
            isEdit
                ? _editField(
                    'Experience (years)',
                    c.experienceController,
                    Icons.work_history,
                  )
                : _infoRow(
                    Icons.work_history_outlined,
                    'Experience',
                    '${data['experience'] ?? '—'} years',
                  ),
            if (data['shopPhotoUrl'] != null &&
                data['shopPhotoUrl'].toString().isNotEmpty) ...[
              const Divider(height: 20),
              Row(
                children: [
                  _iconBox(Icons.photo_camera_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shop Photo', style: _labelStyle),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data['shopPhotoUrl'],
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  // ─────────────────────── SPECIALIZATIONS & SERVICES ───────────────────────
  Widget _specializationsCard(MechanicProfileController c) {
    return _card(
      icon: Icons.build_circle_outlined,
      title: 'Expertise & Services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.specializations.isNotEmpty) ...[
            Text('Specializations', style: _labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: c.specializations
                  .map((s) => _chip(s, _accent))
                  .toList(),
            ),
          ],
          if (c.servicesOffered.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Services Offered', style: _labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: c.servicesOffered
                  .map((s) => _chip(s, const Color(0xFF4CAF50)))
                  .toList(),
            ),
          ],
          if (c.specializations.isEmpty && c.servicesOffered.isEmpty)
            _infoRow(Icons.info_outline, 'Info', 'Not specified yet'),
        ],
      ),
    );
  }

  // ─────────────────────── AVAILABILITY ───────────────────────
  Widget _availabilityCard(
    MechanicProfileController c,
    Map<String, dynamic> data,
  ) {
    return _card(
      icon: Icons.schedule_outlined,
      title: 'Availability',
      child: Column(
        children: [
          _infoRow(Icons.access_time, 'Working Hours', c.workingHoursFormatted),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(Icons.calendar_month_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Days', style: _labelStyle),
                    const SizedBox(height: 6),
                    c.availableDays.isNotEmpty
                        ? Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: c.availableDays
                                .map(
                                  (d) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _accent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      d,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _accent,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : Text(
                            'Not set',
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
          const Divider(height: 20),
          _infoRow(
            Icons.radar,
            'Service Radius',
            '${data['serviceRadius'] ?? '—'} km',
          ),
        ],
      ),
    );
  }

  // ─────────────────────── PRICING ───────────────────────
  Widget _pricingCard(MechanicProfileController c, Map<String, dynamic> data) {
    return Obx(() {
      final isEdit = c.isEditMode.value;
      return _card(
        icon: Icons.currency_rupee,
        title: 'Pricing',
        child: Column(
          children: [
            isEdit
                ? _editField(
                    'Base Charge (₹)',
                    c.baseChargeController,
                    Icons.receipt_long,
                  )
                : _infoRow(
                    Icons.receipt_long_outlined,
                    'Base Charge',
                    '₹${data['baseCharge'] ?? '—'}',
                  ),
            const Divider(height: 20),
            isEdit
                ? _editField('Per Km (₹)', c.perKmChargeController, Icons.route)
                : _infoRow(
                    Icons.route,
                    'Per Km Charge',
                    '₹${data['perKmCharge'] ?? '—'}',
                  ),
            const Divider(height: 20),
            _infoRow(
              Icons.bolt,
              'Emergency Surcharge',
              '₹${data['emergencySurcharge'] ?? '—'}',
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────── VERIFICATION & DOCUMENTS ───────────────────────
  Widget _verificationCard(
    MechanicProfileController c,
    Map<String, dynamic> data,
  ) {
    return _card(
      icon: Icons.verified_user_outlined,
      title: 'Verification & Trust',
      child: Column(
        children: [
          _statusRow('Phone Verified', true, Icons.phone_android),
          const Divider(height: 20),
          _statusRow(
            'Aadhaar Submitted',
            data['aadhaarNumber'] != null &&
                data['aadhaarNumber'].toString().isNotEmpty,
            Icons.credit_card,
          ),
          if (data['aadhaarNumber'] != null &&
              data['aadhaarNumber'].toString().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 4),
              child: Text(
                data['aadhaarNumber'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
          const Divider(height: 20),
          _statusRow(
            'PAN Card',
            data['panCardUrl'] != null &&
                data['panCardUrl'].toString().isNotEmpty,
            Icons.account_balance,
          ),
          const Divider(height: 20),
          _statusRow(
            'Trade License',
            data['tradeLicenseUrl'] != null &&
                data['tradeLicenseUrl'].toString().isNotEmpty,
            Icons.workspace_premium,
          ),
          const Divider(height: 20),
          _statusRow(
            'Bank Account Linked',
            data['bankAccountNumber'] != null &&
                data['bankAccountNumber'].toString().isNotEmpty,
            Icons.account_balance_wallet,
          ),
          if (data['upiId'] != null && data['upiId'].toString().isNotEmpty) ...[
            const Divider(height: 20),
            _infoRow(Icons.qr_code, 'UPI ID', data['upiId']),
          ],
        ],
      ),
    );
  }

  // ─────────────────── REUSABLE WIDGETS ───────────────────

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
    return Row(
      children: [
        _iconBox(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _labelStyle),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: _accent),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
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

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _statusRow(String title, bool verified, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (verified ? Colors.green : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            verified ? Icons.check_circle : Icons.radio_button_unchecked,
            color: verified ? Colors.green : Colors.grey.shade400,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: verified ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        Icon(icon, size: 18, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _saveButton(MechanicProfileController c) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: c.isLoading.value ? null : c.saveProfileInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _logoutButton(MechanicProfileController c) {
    return ElevatedButton.icon(
      onPressed: c.logout,
      icon: const Icon(Icons.logout, color: Colors.white, size: 20),
      label: Text(
        'Logout',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _formatDob(dynamic dob) {
    if (dob == null || dob.toString().isEmpty) return 'Not set';
    try {
      final d = DateTime.parse(dob.toString());
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dob.toString();
    }
  }

  TextStyle get _labelStyle =>
      GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500);
}

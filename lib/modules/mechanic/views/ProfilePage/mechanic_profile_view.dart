import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/mechanic_profile_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class MechanicProfileView extends StatelessWidget {

  static const _accent = Color(0xFF6C63FF);

  const MechanicProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MechanicProfileController());

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: Obx(() {
        final data = c.userData.value;
        if (data == null) {
          return Center(child: CircularProgressIndicator(color: _accent));
        }

        return CustomScrollView(
          slivers: [
            // Gradient AppBar with profile
            _sliverHeader(c, data),

            // Content
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _statsRow(c),
                  SizedBox(height: 16.h),
                  _personalInfoCard(c, data),
                  SizedBox(height: 14.h),
                  _shopInfoCard(c, data),
                  SizedBox(height: 14.h),
                  _specializationsCard(c),
                  SizedBox(height: 14.h),
                  _availabilityCard(c, data),
                  SizedBox(height: 14.h),
                  _pricingCard(c, data),
                  SizedBox(height: 14.h),
                  _verificationCard(c, data),
                  SizedBox(height: 20.h),
                  _logoutButton(c),
                  SizedBox(height: 24.h),
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
        icon: Icon(Icons.arrow_back, color: Colors.white),
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
          decoration: BoxDecoration(
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
                SizedBox(height: 40.h),
                // Avatar
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3.w,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 46.r,
                    backgroundImage: _profileImage(data),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: _profileImage(data) == null
                        ? Icon(
                            Icons.person,
                            size: 46.w,
                            color: Colors.white70,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  c.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                if (data['shopName'] != null &&
                    data['shopName'].toString().isNotEmpty)
                  Text(
                    data['shopName'],
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white70,
                    ),
                  ),
                SizedBox(height: 8.h),
                // Verification Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: c.verificationColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: c.verificationColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        c.verificationColor == Color(0xFF4CAF50)
                            ? Icons.verified
                            : Icons.pending,
                        size: 14.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        c.verificationBadge,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
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
          SizedBox(width: 10.w),
          _statTile(
            Icons.star_rounded,
            'Rating',
            c.rating.value > 0 ? c.rating.value.toStringAsFixed(1) : '—',
            Colors.amber,
          ),
          SizedBox(width: 10.w),
          _statTile(
            Icons.account_balance_wallet,
            'Earned',
            '₹${c.totalEarnings.value.toStringAsFixed(0)}',
            _accent,
          ),
          SizedBox(width: 10.w),
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
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.w),
            SizedBox(height: 6.h),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
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
            Divider(height: 20.h),
            _infoRow(Icons.phone, 'Phone', data['phone'] ?? '—'),
            Divider(height: 20.h),
            isEdit
                ? _editField('Email', c.emailController, Icons.email)
                : _infoRow(
                    Icons.email_outlined,
                    'Email',
                    data['email'] ?? 'Not added',
                  ),
            Divider(height: 20.h),
            _infoRow(
              Icons.cake_outlined,
              'Date of Birth',
              _formatDob(data['dob']),
            ),
            Divider(height: 20.h),
            _infoRow(Icons.person, 'Gender', data['gender'] ?? '—'),
            if (isEdit) ...[SizedBox(height: 16.h), _saveButton(c)],
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
            Divider(height: 20.h),
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
            Divider(height: 20.h),
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
              Divider(height: 20.h),
              Row(
                children: [
                  _iconBox(Icons.photo_camera_outlined),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shop Photo', style: _labelStyle),
                        SizedBox(height: 6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            data['shopPhotoUrl'],
                            height: 100.h,
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
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: c.specializations
                  .map((s) => _chip(s, _accent))
                  .toList(),
            ),
          ],
          if (c.servicesOffered.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text('Services Offered', style: _labelStyle),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: c.servicesOffered
                  .map((s) => _chip(s, Color(0xFF4CAF50)))
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
          Divider(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(Icons.calendar_month_outlined),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Days', style: _labelStyle),
                    SizedBox(height: 6.h),
                    c.availableDays.isNotEmpty
                        ? Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: c.availableDays
                                .map(
                                  (d) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _accent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      d,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
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
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
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
            Divider(height: 20.h),
            isEdit
                ? _editField('Per Km (₹)', c.perKmChargeController, Icons.route)
                : _infoRow(
                    Icons.route,
                    'Per Km Charge',
                    '₹${data['perKmCharge'] ?? '—'}',
                  ),
            Divider(height: 20.h),
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
          Divider(height: 20.h),
          _statusRow(
            'Aadhaar Submitted',
            data['aadhaarNumber'] != null &&
                data['aadhaarNumber'].toString().isNotEmpty,
            Icons.credit_card,
          ),
          if (data['aadhaarNumber'] != null &&
              data['aadhaarNumber'].toString().isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(left: 52.w, top: 4.h),
              child: Text(
                data['aadhaarNumber'],
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
          Divider(height: 20.h),
          _statusRow(
            'PAN Card',
            data['panCardUrl'] != null &&
                data['panCardUrl'].toString().isNotEmpty,
            Icons.account_balance,
          ),
          Divider(height: 20.h),
          _statusRow(
            'Trade License',
            data['tradeLicenseUrl'] != null &&
                data['tradeLicenseUrl'].toString().isNotEmpty,
            Icons.workspace_premium,
          ),
          Divider(height: 20.h),
          _statusRow(
            'Bank Account Linked',
            data['bankAccountNumber'] != null &&
                data['bankAccountNumber'].toString().isNotEmpty,
            Icons.account_balance_wallet,
          ),
          if (data['upiId'] != null && data['upiId'].toString().isNotEmpty) ...[
            Divider(height: 20.h),
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
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.w, color: _accent),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        _iconBox(icon),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _labelStyle),
              SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
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
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, size: 18.w, color: _accent),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13.sp),
        prefixIcon: Icon(icon, size: 20.w, color: _accent),
        filled: false,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _accent, width: 2),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
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
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: (verified ? Colors.green : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            verified ? Icons.check_circle : Icons.radio_button_unchecked,
            color: verified ? Colors.green : Colors.grey.shade400,
            size: 20.w,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: verified ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        Spacer(),
        Icon(icon, size: 18.w, color: Colors.grey.shade300),
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
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: c.isLoading.value
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
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
      icon: Icon(Icons.logout, color: Colors.white, size: 20.w),
      label: Text(
        'Logout',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
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
      GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500);
}

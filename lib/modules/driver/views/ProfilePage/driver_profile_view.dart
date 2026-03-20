import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/driver_profile_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class DriverProfileView extends StatelessWidget {
  static const _accent = Color(0xFF6C63FF);

  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DriverProfileController());

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: Obx(() {
        if (c.userData.value == null) {
          return Center(child: CircularProgressIndicator(color: _accent));
        }

        return CustomScrollView(
          slivers: [
            _buildHeader(c),
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _statsRow(c),
                  SizedBox(height: 16.h),
                  _personalInfoCard(c),
                  SizedBox(height: 16.h),
                  _identityCard(c),
                  SizedBox(height: 24.h),
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
          decoration: BoxDecoration(
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
                SizedBox(height: 15.h),
                // Avatar
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.w),
                  ),
                  child: CircleAvatar(
                    radius: 42.r,
                    backgroundColor: Colors.white24,
                    child: Text(
                      c.displayName.isNotEmpty
                          ? c.displayName[0].toUpperCase()
                          : 'D',
                      style: GoogleFonts.poppins(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
                SizedBox(height: 4.h),
                Text(
                  c.phone,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        c.isOnboarded ? Icons.verified : Icons.pending,
                        size: 14.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        c.isOnboarded ? 'VERIFIED DRIVER' : 'SETUP PENDING',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
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
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
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
          Icon(icon, color: color, size: 22.w),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40.h, color: Colors.grey.shade200);
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
              SizedBox(height: 12.h),
              _editField('Email', c.emailController, Icons.email),
              SizedBox(height: 12.h),
              _editField(
                'Address',
                c.addressController,
                Icons.home,
                maxLines: 2,
              ),
              SizedBox(height: 12.h),
              _editField('Gender', c.genderController, Icons.wc),
              SizedBox(height: 12.h),
              _editField('Date of Birth (YYYY-MM-DD)', c.dobController, Icons.cake),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: c.isLoading.value ? null : c.saveBasicInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ] else ...[
              _infoRow(Icons.person, 'Full Name', c.displayName),
              _sep(),
              _infoRow(Icons.phone, 'Phone', c.phone.isNotEmpty ? c.phone : 'Not added'),
              _sep(),
              _infoRow(Icons.email, 'Email', c.email.isNotEmpty ? c.email : 'Not added'),
              _sep(),
              _infoRow(Icons.home, 'Address', c.address.isNotEmpty ? c.address : 'Not added'),
              _sep(),
              _infoRow(Icons.wc, 'Gender', c.gender.isNotEmpty ? c.gender : 'Not added'),
              _sep(),
              _infoRow(Icons.cake, 'Date of Birth', c.dob.isNotEmpty ? c.dob : 'Not added'),
            ],
          ],
        );
      }),
    );
  }

  // ─── Identity Card ───
  Widget _identityCard(DriverProfileController c) {
    if (c.govtIdType.isEmpty) {
      return SizedBox.shrink();
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
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'ID Verified',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
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

  // ─── Reusable widgets ───
  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.w, color: _accent),
              SizedBox(width: 6.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.w, color: _accent),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: value == 'Not added'
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() =>
      Divider(height: 16.h, thickness: 0.5, color: Colors.grey.shade200);

  Widget _editField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13.sp),
        prefixIcon: Icon(icon, size: 20.w, color: _accent),
        filled: false,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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

  Widget _logoutButton(DriverProfileController c) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: c.logout,
        icon: Icon(Icons.logout),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

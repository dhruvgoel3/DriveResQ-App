import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/helpers/responsive_helper.dart';

/// Shared navigation drawer for both Driver and Mechanic dashboards.
/// [userRole] — 'driver' or 'mechanic' (used for theming).
/// [onHistoryTap] — callback when the History tile is tapped.
class HistoryDrawer extends StatelessWidget {
  final String userRole;
  final VoidCallback onHistoryTap;

  const HistoryDrawer({
    super.key,
    required this.userRole,
    required this.onHistoryTap,
  });

  bool get _isMechanic => userRole == 'mechanic';

  Color get _accentColor =>
      _isMechanic ? AppColors.mechanicPrimary : AppColors.primary;

  LinearGradient get _headerGradient => LinearGradient(
    colors: _isMechanic
        ? [AppColors.mechanicPrimary, AppColors.mechanicAccent]
        : [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Header ──
          _buildHeader(uid),

          // ── Menu Items ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                _DrawerTile(
                  icon: Iconsax.clock,
                  label: 'History',
                  accentColor: _accentColor,
                  onTap: () {
                    Navigator.of(context).pop(); // close drawer
                    onHistoryTap();
                  },
                ),
              ],
            ),
          ),

          // ── Footer ──
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 16.w,
                    color: AppColors.textHint,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'DriveResQ v1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String? uid) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 56.h,
        left: 24.w,
        right: 24.w,
        bottom: 24.h,
      ),
      decoration: BoxDecoration(gradient: _headerGradient),
      child: uid == null
          ? const SizedBox.shrink()
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = _isMechanic ? 'Mechanic' : 'Driver';
                String phone = '';
                String photoUrl = '';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['fullName'] ?? data['name'] ?? name;
                  phone =
                      data['phone'] ??
                      FirebaseAuth.instance.currentUser?.phoneNumber ??
                      '';
                  photoUrl = data['profilePhotoUrl'] ?? '';
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      backgroundImage: photoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? Icon(Iconsax.user, size: 28.w, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (phone.isNotEmpty)
                            Text(
                              phone,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.white70,
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _isMechanic ? '🔧 Mechanic' : '🚗 Driver',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

/// Reusable drawer list tile with accent highlight.
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.mediumAll,
        child: InkWell(
          borderRadius: AppRadius.mediumAll,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mediumAll,
                  ),
                  child: Icon(icon, color: accentColor, size: 22.w),
                ),
                SizedBox(width: 16.w),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 18.w,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

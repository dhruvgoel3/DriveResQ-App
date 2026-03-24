import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// Compact request card for the "All Requests" tab on the mechanic dashboard.
/// Tapping opens a detailed bottom sheet with full info and Accept button.
class OpenRequestCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onAccept;
  final int animationIndex;

  static const _primary = Color(0xFF6C63FF);
  static const _orange = Color(0xFFFF9800);
  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFF44336);

  const OpenRequestCard({
    super.key,
    required this.job,
    this.onAccept,
    this.animationIndex = 0,
  });

  bool get _isUrgent {
    final createdAt = job['createdAt'];
    if (createdAt == null) return false;
    try {
      final ts = createdAt.toDate() as DateTime;
      return DateTime.now().difference(ts).inMinutes > 30;
    } catch (_) {
      return false;
    }
  }

  String get _timeAgo {
    final createdAt = job['createdAt'];
    if (createdAt == null) return '';
    try {
      final ts = createdAt.toDate() as DateTime;
      final diff = DateTime.now().difference(ts);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  String get _distanceText {
    final d = job['distance'];
    if (d == null) return '';
    try {
      final dist = double.parse(d.toString());
      return '${dist.toStringAsFixed(1)} km';
    } catch (_) {
      return '';
    }
  }

  IconData _problemIcon(String? problem) {
    final p = (problem ?? '').toLowerCase();
    if (p.contains('tire') || p.contains('tyre') || p.contains('flat'))
      return Iconsax.car;
    if (p.contains('engine') || p.contains('motor')) return Iconsax.setting_2;
    if (p.contains('battery') || p.contains('charge'))
      return Iconsax.battery_charging;
    if (p.contains('fuel') || p.contains('petrol') || p.contains('diesel'))
      return Iconsax.gas_station;
    if (p.contains('key') || p.contains('lock')) return Iconsax.key;
    return Iconsax.warning_2;
  }

  @override
  Widget build(BuildContext context) {
    final problem = job['problem'] ?? 'Not specified';

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: _isUrgent
              ? Border.all(color: _red.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Problem icon
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(_problemIcon(problem), color: _orange, size: 22.w),
            ),
            SizedBox(width: 12.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          problem,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isUrgent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "URGENT",
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: _red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Iconsax.car,
                        color: Colors.grey.shade500,
                        size: 13.w,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          job['vehicleType'] ?? 'Vehicle',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_distanceText.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Icon(Iconsax.location, color: _primary, size: 13.w),
                        SizedBox(width: 2.w),
                        Text(
                          _distanceText,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ],
                      if (_timeAgo.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Iconsax.clock,
                          color: Colors.grey.shade400,
                          size: 13.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _timeAgo,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Arrow
            Icon(
              Iconsax.arrow_right_3,
              color: Colors.grey.shade400,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    final problem = job['problem'] ?? 'Not specified';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    _problemIcon(problem),
                    color: _orange,
                    size: 28.w,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        problem,
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        job['vehicleType'] ?? 'Vehicle',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isUrgent)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "URGENT",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: _red,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 20.h),
            Divider(color: Colors.grey.shade200),
            SizedBox(height: 16.h),

            // Info rows
            _detailRow(Iconsax.user, "Driver", job['driverName'] ?? 'Unknown'),
            SizedBox(height: 12.h),
            _detailRow(
              Iconsax.location,
              "Location",
              job['locationName'] ?? 'Not available',
            ),
            if (job['landmark'] != null &&
                job['landmark'].toString().isNotEmpty) ...[
              SizedBox(height: 12.h),
              _detailRow(Iconsax.building, "Landmark", job['landmark']),
            ],
            if (_distanceText.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _detailRow(Iconsax.routing, "Distance", _distanceText),
            ],
            if (_timeAgo.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _detailRow(Iconsax.clock, "Created", _timeAgo),
            ],
            if (job['description'] != null &&
                job['description'].toString().isNotEmpty) ...[
              SizedBox(height: 12.h),
              _detailRow(
                Iconsax.document_text,
                "Description",
                job['description'],
              ),
            ],

            SizedBox(height: 24.h),

            // Accept button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onAccept?.call();
                },
                icon: Icon(Iconsax.tick_circle, size: 20.w),
                label: Text(
                  "Accept Request",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primary, size: 18.w),
        SizedBox(width: 10.w),
        SizedBox(
          width: 75.w,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

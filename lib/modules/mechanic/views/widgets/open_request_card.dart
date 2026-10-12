import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../controllers/mechanic_controller.dart';
import '../../../pricing/models/travel_pricing_model.dart';
import '../../../pricing/services/pricing_config_service.dart';
import '../../../pricing/views/widgets/travel_fee_breakdown_widget.dart';

/// Compact request card for the "All Requests" tab on the mechanic dashboard.
/// Tapping opens a detailed bottom sheet with full info, transparent travel fee breakdown, and Accept button.
class OpenRequestCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onAccept;
  final void Function(TravelFeeBreakdown? fee)? onAcceptWithFee;
  final int animationIndex;

  static const _primary = Color(0xFF6C63FF);
  static const _orange = Color(0xFFFF9800);
  static const _red = Color(0xFFF44336);
  static const _green = Color(0xFF10B981);

  const OpenRequestCard({
    super.key,
    required this.job,
    this.onAccept,
    this.onAcceptWithFee,
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

  String? get _estimatedTravelFee {
    if (job['lockedTravelFee'] is Map) {
      final f = (job['lockedTravelFee']['totalFee'] as num?)?.toDouble();
      if (f != null) return '₹${f.toStringAsFixed(0)}';
    }
    if (job['travelFee'] != null) {
      final f = (job['travelFee'] as num).toDouble();
      return '₹${f.toStringAsFixed(0)}';
    }
    final d = job['distance'];
    if (d == null) return null;
    try {
      final dist = double.parse(d.toString());
      final fee = 50.0 + (dist * 20.0);
      return '₹${fee.toStringAsFixed(0)}';
    } catch (_) {
      return null;
    }
  }

  Future<TravelFeeBreakdown> _fetchFee() async {
    if (Get.isRegistered<MechanicController>()) {
      return Get.find<MechanicController>().calculateFeeForRequest(job);
    }
    final dist = double.tryParse(job['distance']?.toString() ?? '0') ?? 0.0;
    final config = await PricingConfigService.fetchPricingConfig();
    return PricingConfigService.calculateTravelFee(
      distanceKm: dist,
      config: config,
    );
  }

  IconData _problemIcon(String? problem) {
    final p = (problem ?? '').toLowerCase();
    if (p.contains('tire') || p.contains('tyre') || p.contains('flat')) {
      return Iconsax.car;
    }
    if (p.contains('engine') || p.contains('motor')) return Iconsax.setting_2;
    if (p.contains('battery') || p.contains('charge')) {
      return Iconsax.battery_charging;
    }
    if (p.contains('fuel') || p.contains('petrol') || p.contains('diesel')) {
      return Iconsax.gas_station;
    }
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
              ? Border.all(color: _red.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                color: _orange.withValues(alpha: 0.1),
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
                            color: _red.withValues(alpha: 0.1),
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
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.car,
                            color: Colors.grey.shade500,
                            size: 13.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            job['vehicleType'] ?? 'Vehicle',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      if (_distanceText.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                        ),
                      if (_estimatedTravelFee != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _estimatedTravelFee!,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      if (_timeAgo.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                        ),
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
    TravelFeeBreakdown? calculatedFee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                    color: _orange.withValues(alpha: 0.1),
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
                      color: _red.withValues(alpha: 0.1),
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
            Builder(
              builder: (context) {
                final driverId = job['driverId'] as String?;
                return FutureBuilder<DocumentSnapshot?>(
                  future: driverId != null
                      ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(driverId)
                            .get()
                      : Future.value(null),
                  builder: (context, snapshot) {
                    double rating = 0.0;
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      rating = (data['averageRating'] ?? 0.0).toDouble();
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Iconsax.user, color: _primary, size: 18.w),
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: 75.w,
                          child: Text(
                            "Driver",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  job['driverName'] ?? 'Unknown',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (rating > 0) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Iconsax.star1,
                                  color: _orange,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _orange,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
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

            SizedBox(height: 16.h),

            // Transparent Travel Fee Breakdown
            FutureBuilder<TravelFeeBreakdown>(
              future: _fetchFee(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Calculating driving distance & travel fee...",
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  calculatedFee = snapshot.data!;
                  return TravelFeeBreakdownWidget(
                    breakdown: snapshot.data!,
                    isLocked: false,
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            SizedBox(height: 20.h),

            // Accept button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (onAcceptWithFee != null) {
                    onAcceptWithFee!(calculatedFee);
                  } else {
                    onAccept?.call();
                  }
                },
                icon: Icon(Iconsax.tick_circle, size: 20.w),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Accept Request",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
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

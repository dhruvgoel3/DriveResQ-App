import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/helpers/responsive_helper.dart';
import '../../models/travel_pricing_model.dart';

/// A transparent, high-trust UI widget that displays the locked Mechanic Travel Fee
/// and shows the exact mathematical breakdown of how the fare is computed.
class TravelFeeBreakdownWidget extends StatefulWidget {
  final TravelFeeBreakdown breakdown;
  final bool isLocked;
  final bool isCompact;

  const TravelFeeBreakdownWidget({
    super.key,
    required this.breakdown,
    this.isLocked = true,
    this.isCompact = false,
  });

  @override
  State<TravelFeeBreakdownWidget> createState() => _TravelFeeBreakdownWidgetState();
}

class _TravelFeeBreakdownWidgetState extends State<TravelFeeBreakdownWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.breakdown;
    final totalFormatted = '₹${b.totalFee.toStringAsFixed(2)}';
    final baseFormatted = '₹${b.baseDispatchFee.toStringAsFixed(2)}';
    final distChargeFormatted = '₹${b.distanceCharge.toStringAsFixed(2)}';
    final perKmFormatted = '₹${b.perKmRate.toStringAsFixed(2)}';
    final distFormatted = '${b.distanceKm.toStringAsFixed(1)} km';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.isLocked ? const Color(0xFF10B981).withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
          width: widget.isLocked ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header / Total Banner ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: widget.isLocked ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: widget.isLocked ? const Color(0xFF10B981) : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isLocked ? Iconsax.lock : Iconsax.calculator,
                    size: 14.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isLocked ? 'Locked Travel Fee' : 'Estimated Travel Fee',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.isLocked ? const Color(0xFF065F46) : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Base fee + $distFormatted distance',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: widget.isLocked ? const Color(0xFF047857) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  totalFormatted,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: widget.isLocked ? const Color(0xFF065F46) : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Math Breakdown Section ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Math formula summary
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _mathPill('Base Fee', baseFormatted),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text('+', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textHint)),
                      ),
                      Expanded(
                        flex: 4,
                        child: _mathPill('Distance ($distFormatted)', distChargeFormatted),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text('=', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textHint)),
                      ),
                      Expanded(
                        flex: 3,
                        child: _mathPill('Total', totalFormatted, isHighlight: true),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Per-KM Rate Formula Dropdown Toggle
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Icon(Iconsax.info_circle, size: 14.w, color: AppColors.primary),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            'Transparent rate breakdown ($perKmFormatted/km)',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                          size: 14.w,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_isExpanded) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      children: [
                        _costRow('Fuel (₹103.32 ÷ 45 km/l)', '₹${b.fuelCost.toStringAsFixed(2)}', '₹2.30/km'),
                        SizedBox(height: 4.h),
                        _costRow('Vehicle Wear & Tear', '₹${b.wearTearCost.toStringAsFixed(2)}', '₹1.50/km'),
                        SizedBox(height: 4.h),
                        _costRow('Time & Labor Compensation', '₹${b.timeLaborCost.toStringAsFixed(2)}', '₹8.20/km'),
                        const Divider(height: 12),
                        _costRow('Total Driving Rate', distChargeFormatted, '$perKmFormatted/km', isBold: true),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 10.h),

                // ── Mandatory Transparency Disclaimer ───────────────────────
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Iconsax.shield_security, size: 14.w, color: const Color(0xFFD97706)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Travel fee is fixed. Spare parts and repair labor will be added after inspection.',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF92400E),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mathPill(String label, String value, {bool isHighlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _costRow(String title, String total, String rate, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '($rate)  ',
              style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textHint),
            ),
            Text(
              total,
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: isBold ? AppColors.textPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

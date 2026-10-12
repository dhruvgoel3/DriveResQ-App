import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/helpers/responsive_helper.dart';
import '../../models/travel_pricing_model.dart';
import 'travel_fee_breakdown_widget.dart';

/// Modal bottom sheet presenting the locked mechanic travel fee breakdown.
class TravelFeeBottomSheet extends StatelessWidget {
  final TravelFeeBreakdown breakdown;
  final bool isLocked;
  final VoidCallback? onConfirm;
  final String? confirmButtonText;

  const TravelFeeBottomSheet({
    super.key,
    required this.breakdown,
    this.isLocked = true,
    this.onConfirm,
    this.confirmButtonText,
  });

  static Future<void> show(
    BuildContext context, {
    required TravelFeeBreakdown breakdown,
    bool isLocked = true,
    VoidCallback? onConfirm,
    String? confirmButtonText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TravelFeeBottomSheet(
        breakdown: breakdown,
        isLocked: isLocked,
        onConfirm: onConfirm,
        confirmButtonText: confirmButtonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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
          SizedBox(height: 18.h),

          // Title
          Row(
            children: [
              Icon(Iconsax.receipt_2, size: 22.w, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(
                'Mechanic Travel Fee Details',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Core Fee Widget
          TravelFeeBreakdownWidget(
            breakdown: breakdown,
            isLocked: isLocked,
          ),

          if (onConfirm != null) ...[
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm?.call();
                },
                icon: const Icon(Iconsax.tick_circle, color: Colors.white),
                label: Text(
                  confirmButtonText ?? 'Confirm & Accept',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

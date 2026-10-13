import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/app/routes/app_pages.dart';
import 'package:driveresq_app/modules/dues/services/dues_service.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// Compact profile card displaying current platform dues and quick settlement action.
class PlatformDuesCard extends StatelessWidget {
  const PlatformDuesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: DuesService.streamOutstanding(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final outstanding =
            (data?['platformDueOutstanding'] as num?)?.toDouble() ?? 0.0;
        final isSuspended =
            data?['accountStatus'] == 'suspended' || outstanding > 0;

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                  Icon(
                    Iconsax.wallet_3,
                    size: 20.w,
                    color: const Color(0xFF6C63FF),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Platform Dues',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isSuspended
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSuspended
                              ? Iconsax.info_circle
                              : Iconsax.tick_circle,
                          size: 12.w,
                          color: isSuspended
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isSuspended ? 'Due Pending' : 'Settled',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isSuspended
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '₹${outstanding.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: isSuspended
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.MECHANIC_DUES),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuspended
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isSuspended ? 'Pay Dues' : 'View Ledger',
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isSuspended) ...[
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.warning_2,
                        size: 16.w,
                        color: const Color(0xFFE65100),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Account is paused until outstanding commission is cleared.',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: const Color(0xFFE65100),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

import '../../../controllers/driver_profile_controller.dart';

class ProfileStats extends StatelessWidget {
  final DriverProfileController controller;
  const ProfileStats({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem(
            'Requests',
            controller.totalRequests.value.toString(),
            Iconsax.send_1,
            AppColors.info,
          ),
          _divider(),
          _statItem(
            'Completed',
            controller.completedRequests.value.toString(),
            Iconsax.tick_circle,
            AppColors.success,
          ),
          _divider(),
          _statItem(
            'Spent',
            '₹${controller.totalSpent.value.toStringAsFixed(0)}',
            Iconsax.wallet,
            AppColors.secondary,
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
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11.sp)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40.h,
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}

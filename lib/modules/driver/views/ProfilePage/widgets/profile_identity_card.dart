import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import '../../../controllers/driver_profile_controller.dart';
import 'profile_card_container.dart';

class ProfileIdentityCard extends StatelessWidget {
  final DriverProfileController controller;
  const ProfileIdentityCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.govtIdType.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProfileCardContainer(
      title: 'IDENTITY VERIFICATION',
      icon: Iconsax.verify,
      child: Column(
        children: [
          _infoRow(Iconsax.card, 'ID Type', controller.govtIdType),
          _sep(),
          _infoRow(Iconsax.math, 'ID Number', controller.govtIdNumber),
          _sep(),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Iconsax.tick_circle,
                  color: AppColors.success,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'ID Verified',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
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
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.w, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                ),
                Text(
                  value,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() => Divider(
    height: 16.h,
    thickness: 0.5,
    color: AppColors.border.withValues(alpha: 0.5),
  );
}

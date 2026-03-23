import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

import '../../../controllers/driver_profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  final DriverProfileController controller;
  const ProfileHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isEditMode.value ? Iconsax.close_square : Iconsax.edit_2,
              color: AppColors.surface,
            ),
            onPressed: controller.toggleEditMode,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
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
                    border: Border.all(color: AppColors.surface, width: 3.w),
                  ),
                  child: CircleAvatar(
                    radius: 42.r,
                    backgroundColor: AppColors.surface.withOpacity(0.24),
                    child: Text(
                      controller.displayName.isNotEmpty
                          ? controller.displayName[0].toUpperCase()
                          : 'D',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 36.sp,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  controller.displayName,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.surface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.phone,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.surface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isOnboarded ? Iconsax.verify : Iconsax.clock,
                        size: 14.w,
                        color: AppColors.surface,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        controller.isOnboarded ? 'VERIFIED DRIVER' : 'SETUP PENDING',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.surface,
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
}

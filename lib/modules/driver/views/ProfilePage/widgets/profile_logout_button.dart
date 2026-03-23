import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

import '../../../controllers/driver_profile_controller.dart';

class ProfileLogoutButton extends StatelessWidget {
  final DriverProfileController controller;
  const ProfileLogoutButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout, color: AppColors.surface),
        label: Text(
          'Logout',
          style: AppTextStyles.button.copyWith(color: AppColors.surface),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.surface,
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

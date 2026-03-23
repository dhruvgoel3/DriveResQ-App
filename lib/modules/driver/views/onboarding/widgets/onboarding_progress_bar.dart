import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

import '../../../controllers/driver_onboarding_controller.dart';

class OnboardingProgressBar extends StatelessWidget {
  final DriverOnboardingController controller;
  const OnboardingProgressBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${controller.currentStep.value + 1} of 2',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                controller.currentStep.value == 0
                    ? 'Personal Details'
                    : 'ID Verification',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: (controller.currentStep.value + 1) / 2,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 4.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }
}

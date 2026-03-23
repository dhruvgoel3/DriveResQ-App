import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import '../../../controllers/driver_onboarding_controller.dart';
import 'onboarding_shared.dart';

class OnboardingStepTwo extends StatelessWidget {
  final DriverOnboardingController controller;
  const OnboardingStepTwo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingShared.sectionTitle('🪪 Identity Verification'),
        SizedBox(height: 6.h),
        Text(
          'Upload any one government ID to verify your identity',
          style: AppTextStyles.caption.copyWith(fontSize: 13.sp),
        ),
        SizedBox(height: 24.h),

        // ID Type selector
        Text(
          'ID Type *',
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedIdType.value,
                isExpanded: true,
                style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500),
                items: controller.idTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) =>
                    controller.selectedIdType.value = v ?? controller.selectedIdType.value,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        OnboardingShared.inputField(
          'ID Number *',
          controller.idNumberController,
          Iconsax.card,
          hint: 'Enter your ID number',
        ),
        SizedBox(height: 20.h),

        // Front photo
        Text(
          'ID Front Photo *',
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => OnboardingShared.photoUploader(
            path: controller.idFrontPath.value,
            label: 'Upload front of your ID',
            onTap: () => controller.pickIdPhoto(isFront: true),
          ),
        ),
        SizedBox(height: 16.h),

        // Back photo (optional)
        Text(
          'ID Back Photo (optional)',
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => OnboardingShared.photoUploader(
            path: controller.idBackPath.value,
            label: 'Upload back of your ID',
            onTap: () => controller.pickIdPhoto(isFront: false),
          ),
        ),
      ],
    );
  }
}

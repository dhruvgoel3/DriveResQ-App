import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import '../../../controllers/driver_onboarding_controller.dart';
import 'onboarding_shared.dart';

class OnboardingStepOne extends StatelessWidget {
  final DriverOnboardingController controller;
  const OnboardingStepOne({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingShared.sectionTitle('👋 Tell us about yourself'),
        SizedBox(height: 6.h),
        Text(
          'This helps us personalize your experience',
          style: AppTextStyles.caption.copyWith(fontSize: 13.sp),
        ),
        SizedBox(height: 24.h),

        OnboardingShared.inputField(
          'Full Name *',
          controller.nameController,
          Iconsax.user,
          hint: 'Enter your full name',
        ),
        SizedBox(height: 16.h),

        OnboardingShared.inputField(
          'Email (optional)',
          controller.emailController,
          Iconsax.sms,
          hint: 'yourname@email.com',
          keyboard: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),

        OnboardingShared.inputField(
          'Address *',
          controller.addressController,
          Iconsax.home,
          hint: 'Your home/contact address',
          maxLines: 2,
        ),
        SizedBox(height: 16.h),

        // Gender
        Text(
          'Gender *',
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Wrap(
            spacing: 10,
            children: ['Male', 'Female', 'Other'].map((g) {
              final selected = controller.gender.value == g;
              return ChoiceChip(
                label: Text(
                  g,
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 13.sp,
                    color: selected ? AppColors.surface : AppColors.textPrimary,
                  ),
                ),
                selected: selected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                onSelected: (_) => controller.gender.value = g,
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.h),

        // DOB
        Text(
          'Date of Birth (optional)',
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => InkWell(
            onTap: () => controller.pickDob(context),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Iconsax.cake, size: 20.w, color: AppColors.primary),
                  SizedBox(width: 12.w),
                  Text(
                    controller.dob.value != null
                        ? '${controller.dob.value!.day}/${controller.dob.value!.month}/${controller.dob.value!.year}'
                        : 'Select date of birth',
                    style: AppTextStyles.body2.copyWith(
                      color: controller.dob.value != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

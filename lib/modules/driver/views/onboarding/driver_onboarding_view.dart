import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

import '../../controllers/driver_onboarding_controller.dart';
import 'widgets/onboarding_progress_bar.dart';
import 'widgets/onboarding_step_one.dart';
import 'widgets/onboarding_step_two.dart';
import 'widgets/onboarding_bottom_button.dart';

class DriverOnboardingView extends StatelessWidget {
  const DriverOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DriverOnboardingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Setup Your Profile',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        leading: Obx(
          () => c.currentStep.value > 0
              ? IconButton(
                  icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
                  onPressed: c.previousStep,
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            // Progress bar
            OnboardingProgressBar(controller: c),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: c.currentStep.value == 0
                    ? OnboardingStepOne(controller: c)
                    : OnboardingStepTwo(controller: c),
              ),
            ),

            // Bottom button
            OnboardingBottomButton(controller: c),
          ],
        );
      }),
    );
  }
}

import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import '../controllers/job_completion_controller.dart';
import 'completion/step1_job_summary.dart';
import 'completion/step3_rating.dart';
import 'completion/step4_completion_success.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class JobCompletionPage extends StatelessWidget {
  const JobCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    // Init job data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && c.jobData.value == null) {
      c.initJob(args['job'], args['jobId']);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (c.currentStep.value > 0 && c.currentStep.value < 2) {
          c.prevStep();
        } else if (c.currentStep.value == 0) {
          Get.back();
        }
        // On success step (2), block back entirely
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Obx(() => _buildAppBar(c)),
        ),
        body: Obx(() {
          switch (c.currentStep.value) {
            case 0:
              return const JobSummaryView();
            case 1:
              return const RatingView();
            case 2:
              return const CompletionSuccessView();
            default:
              return const JobSummaryView();
          }
        }),
      ),
    );
  }

  Widget _buildAppBar(JobCompletionController c) {
    final isSuccess = c.currentStep.value == 2;
    final step = c.currentStep.value;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                if (!isSuccess)
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
                    onPressed: () {
                      if (step > 0) {
                        c.prevStep();
                      } else {
                        Get.back();
                      }
                    },
                  )
                else
                  SizedBox(width: 48.w),
                Expanded(
                  child: Text(
                    isSuccess ? 'Completed!' : _stepTitle(step),
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
          ),

          // Progress Bar (2 segments: Summary → Rating)
          if (!isSuccess)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              child: Row(
                children: List.generate(2, (i) {
                  final active = i <= step;
                  return Expanded(
                    child: Container(
                      height: 4.h,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.success
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Job Summary';
      case 1:
        return 'Rate Customer';
      default:
        return '';
    }
  }
}

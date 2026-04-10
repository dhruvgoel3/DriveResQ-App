import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/job_completion_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';

class RatingView extends StatelessWidget {
  const RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // Driver avatar
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppColors.success.withOpacity(0.1),
            child: Icon(
              Iconsax.user,
              size: 44.w,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            'Rate Your Customer',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'How was your experience with the driver?',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: 28.h),

          // Star Rating
          Text(
            'Overall Experience',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < c.mechanicRating.value;
                return GestureDetector(
                  onTap: () => c.mechanicRating.value = (i + 1).toDouble(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Icon(
                      filled ? Iconsax.star : Iconsax.star,
                      size: 48.w,
                      color: filled ? AppColors.warning : AppColors.border,
                    ),
                  ),
                );
              }),
            ),
          ),
          Obx(
            () => Text(
              _ratingLabel(c.mechanicRating.value),
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: c.mechanicRating.value > 0
                    ? AppColors.warning
                    : AppColors.textHint,
              ),
            ),
          ),

          SizedBox(height: 28.h),

          // Quick Tags
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tags',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: JobCompletionController.ratingTags.map((tag) {
                      final selected = c.quickTags.contains(tag);
                      return FilterChip(
                        selected: selected,
                        label: Text(
                          tag,
                          style: AppTextStyles.caption.copyWith(
                            color: selected
                                ? AppColors.surface
                                : AppColors.textSecondary,
                          ),
                        ),
                        onSelected: (_) => c.toggleTag(tag),
                        selectedColor: AppColors.success,
                        backgroundColor: AppColors.surface,
                        checkmarkColor: AppColors.surface,
                        side: BorderSide(
                          color: selected
                              ? AppColors.success
                              : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Review Text
          TextField(
            controller: c.reviewController,
            maxLines: 3,
            maxLength: 500,
            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Write a review (optional)',
              hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),

          SizedBox(height: 28.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => c.prevStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: c.isLoading.value
                        ? null
                        : () => c.submitCompletion(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.border,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: c.isLoading.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              color: AppColors.surface,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit & Complete',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.surface,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Skip option
          TextButton(
            onPressed: c.isLoading.value ? null : () => c.submitCompletion(),
            child: Text(
              'Skip Rating',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  String _ratingLabel(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap to rate';
    }
  }
}

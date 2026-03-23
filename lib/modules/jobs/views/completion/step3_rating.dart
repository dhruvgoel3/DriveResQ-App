import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

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
            backgroundColor: Color(0xFF4CAF50).withOpacity(0.1),
            child: Icon(Iconsax.user, size: 44.w, color: Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16.h),

          Text(
            'Rate Your Customer',
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'How was your experience with the driver?',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),

          SizedBox(height: 28.h),

          // Star Rating
          Text(
            'Overall Experience',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
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
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Icon(
                      filled ? Iconsax.star : Iconsax.star,
                      size: 48.w,
                      color: filled ? Color(0xFFFFB300) : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
          ),
          Obx(
            () => Text(
              _ratingLabel(c.mechanicRating.value),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: c.mechanicRating.value > 0
                    ? Color(0xFFFFB300)
                    : Colors.grey.shade400,
              ),
            ),
          ),

          SizedBox(height: 28.h),

          // Quick Tags
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tags',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
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
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: selected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                        onSelected: (_) => c.toggleTag(tag),
                        selectedColor: Color(0xFF4CAF50),
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: selected
                              ? Color(0xFF4CAF50)
                              : Colors.grey.shade300,
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
            style: GoogleFonts.poppins(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Write a review (optional)',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              filled: false,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
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
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
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
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit & Complete',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
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
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13.sp,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';

class RatingView extends StatelessWidget {
  const RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Driver avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
            child: const Icon(Icons.person, size: 44, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 16),

          Text(
            'Rate Your Customer',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How was your experience with the driver?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 28),

          // Star Rating
          Text(
            'Overall Experience',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < c.mechanicRating.value;
                return GestureDetector(
                  onTap: () => c.mechanicRating.value = (i + 1).toDouble(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 48,
                      color: filled
                          ? const Color(0xFFFFB300)
                          : Colors.grey.shade300,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.mechanicRating.value > 0
                    ? const Color(0xFFFFB300)
                    : Colors.grey.shade400,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Quick Tags
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tags',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
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
                            fontSize: 12,
                            color: selected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                        onSelected: (_) => c.toggleTag(tag),
                        selectedColor: const Color(0xFF4CAF50),
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Review Text
          TextField(
            controller: c.reviewController,
            maxLines: 3,
            maxLength: 500,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Write a review (optional)',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => c.prevStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: c.isLoading.value
                        ? null
                        : () => c.submitCompletion(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: c.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit & Complete',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Skip option
          TextButton(
            onPressed: c.isLoading.value ? null : () => c.submitCompletion(),
            child: Text(
              'Skip Rating',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 20),
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

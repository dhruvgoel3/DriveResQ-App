import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../theme/app_colors.dart';
import '../../../../utils/helpers/responsive_helper.dart';

class SuggestedPromptList extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onSelected;

  const SuggestedPromptList({
    super.key,
    required this.prompts,
    required this.onSelected,
  });

  IconData _getIconForPrompt(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('start')) return Iconsax.flash;
    if (lower.contains('tyre') || lower.contains('tire')) return Iconsax.radar_2;
    if (lower.contains('heat') || lower.contains('engine')) return Iconsax.danger;
    if (lower.contains('highway')) return Iconsax.warning_2;
    if (lower.contains('mechanic') || lower.contains('wait')) return Iconsax.clock;
    return Iconsax.message_question;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          final icon = _getIconForPrompt(prompt);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(prompt),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14.w, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    Text(
                      prompt,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

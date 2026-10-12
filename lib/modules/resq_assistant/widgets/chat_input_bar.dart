import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../theme/app_colors.dart';
import '../../../../utils/helpers/responsive_helper.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text Input Field
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 120.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.multiline,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: "Type in English or Hinglish (e.g. Gaadi start nahi ho rahi)...",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) onSend();
                  },
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Send Button
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isLoading
                      ? [Colors.grey.shade400, Colors.grey.shade400]
                      : [AppColors.primary, const Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onSend,
                  borderRadius: BorderRadius.circular(22.r),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Iconsax.send_1,
                            color: Colors.white,
                            size: 18.w,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

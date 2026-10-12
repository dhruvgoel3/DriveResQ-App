import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../theme/app_colors.dart';
import '../../../../utils/helpers/app_snackbar.dart';
import '../../../../utils/helpers/responsive_helper.dart';
import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble();
    }
    return _buildAssistantBubble();
  }

  // ── USER MESSAGE BUBBLE (RIGHT) ──
  Widget _buildUserBubble() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF5A52D5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(4.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.white,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ASSISTANT MESSAGE BUBBLE (LEFT) ──
  Widget _buildAssistantBubble() {
    final isError = message.status == MessageStatus.error;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ResQ Assistant Avatar
          Container(
            width: 34.w,
            height: 34.w,
            margin: EdgeInsets.only(top: 2.h, right: 10.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isError
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFEEF2FF),
              border: Border.all(
                color: isError
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFC7D2FE),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                isError ? Iconsax.warning_2 : Iconsax.flash_15,
                size: 18.w,
                color: isError ? AppColors.error : AppColors.primary,
              ),
            ),
          ),

          // Message Card
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isError ? const Color(0xFFFEF2F2) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                border: Border.all(
                  color: isError
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isError ? "Safety Notice" : "ResQ Assistant",
                        style: GoogleFonts.poppins(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isError
                              ? const Color(0xFFDC2626)
                              : AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Iconsax.copy, size: 14.w, color: Colors.grey.shade400),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: "Copy text",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          AppSnackbar.info('Message copied to clipboard');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Message body
                  _renderFormattedText(message.text, isError),

                  // Retry button if error
                  if (isError && onRetry != null) ...[
                    SizedBox(height: 10.h),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: Icon(Iconsax.refresh, size: 14.w),
                      label: Text(
                        "Retry Question",
                        style: GoogleFonts.inter(fontSize: 11.5.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderFormattedText(String text, bool isError) {
    // Process bullet points and bold headers cleanly
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        widgets.add(SizedBox(height: 6.h));
        continue;
      }

      final isWarning = line.contains('⚠️') || line.toLowerCase().contains('warning:');

      if (isWarning) {
        widgets.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              line,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Text(
            line.replaceAll('**', ''),
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              color: isError ? const Color(0xFF991B1B) : const Color(0xFF1E293B),
              height: 1.45,
              fontWeight: line.startsWith('-') || line.startsWith('•')
                  ? FontWeight.w500
                  : FontWeight.w400,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

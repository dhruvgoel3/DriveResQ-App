import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme/app_colors.dart';
import '../../../../utils/helpers/responsive_helper.dart';
import '../controllers/resq_assistant_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/suggested_prompt_chip.dart';

class ResQAssistantScreen extends GetView<ResQAssistantController> {
  const ResQAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // ── Optional Roadside Request Context Banner ──
          _buildRequestContextBanner(),

          // ── Scrollable Chat Messages Canvas ──
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show typing / thinking indicator at the bottom
                  if (index == controller.messages.length) {
                    return _buildTypingIndicator();
                  }

                  final msg = controller.messages[index];
                  return ChatMessageBubble(
                    message: msg,
                    onRetry: controller.retryLastMessage,
                  );
                },
              ),
            ),
          ),

          // ── Suggested Safety Prompts (Always Available) ──
          Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();
            return SuggestedPromptList(
              prompts: controller.suggestedPrompts,
              onSelected: controller.sendSuggestedPrompt,
            );
          }),

          // ── Input Bar ──
          Obx(
            () => ChatInputBar(
              controller: controller.textController,
              focusNode: controller.focusNode,
              isLoading: controller.isLoading.value,
              onSend: controller.sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR WITH SAFETY BADGE & EMERGENCY SOS ──
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Center(
              child: Icon(Iconsax.flash_15, color: Colors.white, size: 18),
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "ResQ Assistant",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        "AI",
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "English • Hinglish Roadside AI",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // 112 Emergency Shortcut
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Icon(Iconsax.call5, size: 16.w, color: AppColors.error),
          ),
          tooltip: "Emergency SOS (112)",
          onPressed: () async {
            final uri = Uri.parse('tel:112');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),

        // Reset conversation
        PopupMenuButton<String>(
          icon: Icon(Iconsax.more, size: 20.w, color: AppColors.textSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          onSelected: (value) {
            if (value == 'clear') {
              controller.clearConversation();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Iconsax.refresh, size: 16.w, color: AppColors.textPrimary),
                  SizedBox(width: 8.w),
                  Text("Clear Chat", style: GoogleFonts.inter(fontSize: 13.sp)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── ACTIVE ROADSIDE REQUEST CONTEXT BANNER ──
  Widget _buildRequestContextBanner() {
    return Obx(() {
      final ctx = controller.activeRequestContext.value;
      if (ctx == null) return const SizedBox.shrink();

      final category = ctx['breakdownCategory'] ?? 'Roadside Breakdown';
      final status = ctx['requestStatus'] ?? 'active';

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBEB),
          border: Border(
            bottom: BorderSide(color: Color(0xFFFDE68A), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(Iconsax.info_circle, size: 16.w, color: const Color(0xFFD97706)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                "Your roadside assistance request is active ($category • Status: $status).",
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF92400E),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── TYPING / THINKING INDICATOR ──
  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  "ResQ Assistant is reviewing vehicle safety...",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

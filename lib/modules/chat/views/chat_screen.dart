import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';
import '../widgets/price_quote_card.dart';
import '../widgets/quick_replies.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ChatAppBar(controller: c),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (c.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.message,
                        size: 64.w,
                        color: AppColors.textHint.withOpacity(0.5),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No messages yet',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Say hello! 👋',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: c.scrollController,
                reverse: true,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                itemCount: c.messages.length,
                itemBuilder: (_, i) {
                  final msg = c.messages[i];
                  final isMe = c.isMe(msg);

                  if (msg.type == 'price_quote') {
                    return PriceQuoteCard(
                      message: msg,
                      isMe: isMe,
                      controller: c,
                    );
                  }

                  return MessageBubble(message: msg, isMe: isMe);
                },
              );
            }),
          ),

          Obx(
            () => c.showQuickReplies.value
                ? QuickRepliesBar(
                    replies: c.quickReplies,
                    onTap: c.sendQuickReply,
                  )
                : const SizedBox.shrink(),
          ),

          Obx(
            () => c.isRecording.value
                ? _ChatRecordingOverlay(controller: c)
                : const SizedBox.shrink(),
          ),

          _ChatInputBar(controller: c),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatController controller;

  const _ChatAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 0,
      leadingWidth: 36.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: IconButton(
          icon: Icon(Iconsax.arrow_left, size: 22.w),
          onPressed: () => Get.back(),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: controller.otherUserPhoto.isNotEmpty
                ? NetworkImage(controller.otherUserPhoto)
                : null,
            backgroundColor: AppColors.surface.withOpacity(0.24),
            child: controller.otherUserPhoto.isEmpty
                ? Icon(
                    Iconsax.user,
                    color: AppColors.surface.withOpacity(0.7),
                    size: 18.w,
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.otherUserName,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface,
                  ),
                ),
                Text(
                  controller.myRole == 'driver' ? 'Mechanic' : 'Driver',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.surface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (controller.myRole == 'mechanic')
          IconButton(
            icon: Icon(Iconsax.receipt_item, size: 22.w),
            tooltip: 'Send Estimate',
            onPressed: () => _EstimateDialog.show(controller),
          ),
        IconButton(
          icon: Icon(Iconsax.call, size: 22.w),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatRecordingOverlay extends StatelessWidget {
  final ChatController controller;

  const _ChatRecordingOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: AppColors.error.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (_, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Recording',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: 8.w),
          Obx(
            () => Text(
              controller.formatRecordingDuration(),
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.error.withOpacity(0.8),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: controller.cancelRecording,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.trash,
                    size: 16.w,
                    color: AppColors.error,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Cancel',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.stopAndSendRecording,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.send_1, color: AppColors.surface, size: 20.w),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final ChatController controller;

  const _ChatInputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8.w,
        right: 8.w,
        top: 8.h,
        bottom: MediaQuery.of(context).padding.bottom + 8.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isRecording.value) return const SizedBox.shrink();

        return Row(
          children: [
            IconButton(
              icon: Icon(
                Iconsax.add_circle,
                color: AppColors.textHint,
                size: 24.w,
              ),
              onPressed: () => _showAttachMenu(context, controller),
            ),
            Obx(
              () => IconButton(
                icon: Icon(
                  Iconsax.flash,
                  color: controller.showQuickReplies.value
                      ? AppColors.primary
                      : AppColors.textHint,
                  size: 24.w,
                ),
                onPressed: () => controller.showQuickReplies.value =
                    !controller.showQuickReplies.value,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: controller.textController,
                  style: AppTextStyles.body2,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textHint,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            _buildSendOrMicButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildSendOrMicButton(ChatController c) {
    return Obx(() {
      final hasText = c.hasText.value;
      final sending = c.isSending.value;

      if (sending) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.border,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(
                color: AppColors.surface,
                strokeWidth: 2,
              ),
            ),
            onPressed: null,
          ),
        );
      }

      if (hasText) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Iconsax.send_1, color: AppColors.surface, size: 20.w),
            onPressed: c.sendMessage,
          ),
        );
      }

      return Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Iconsax.microphone, color: AppColors.surface, size: 22.w),
          onPressed: c.startRecording,
        ),
      );
    });
  }

  void _showAttachMenu(BuildContext context, ChatController c) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachOption(Iconsax.camera, 'Camera', AppColors.error, () {
                  Get.back();
                  c.pickAndSendImage(source: ImageSource.camera);
                }),
                _attachOption(Iconsax.gallery, 'Gallery', AppColors.primary, () {
                  Get.back();
                  c.pickAndSendImage(source: ImageSource.gallery);
                }),
                _attachOption(
                  Iconsax.location,
                  'Location',
                  AppColors.success,
                  () {
                    Get.back();
                    c.sendQuickReply('📍 Sharing my current location');
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _attachOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26.w),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimateDialog {
  static void show(ChatController c) {
    final serviceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Send Service Estimate', style: AppTextStyles.h2),
              SizedBox(height: 16.h),
              TextField(
                controller: serviceCtrl,
                style: AppTextStyles.body2,
                decoration: InputDecoration(
                  labelText: 'Service Description *',
                  labelStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costCtrl,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.body2,
                      decoration: InputDecoration(
                        labelText: 'Cost (₹) *',
                        labelStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: timeCtrl,
                      style: AppTextStyles.body2,
                      decoration: InputDecoration(
                        labelText: 'Est. Time *',
                        hintText: 'e.g. 1 hour',
                        labelStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        hintStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.textHint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                style: AppTextStyles.body2,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final cost = double.tryParse(costCtrl.text);
                    if (serviceCtrl.text.trim().isEmpty ||
                        cost == null ||
                        timeCtrl.text.trim().isEmpty) {
                      Get.snackbar(
                        'Required',
                        'Fill service, cost and time',
                        backgroundColor: AppColors.error,
                        colorText: AppColors.surface,
                      );
                      return;
                    }
                    Get.back();
                    c.sendEstimate(
                      service: serviceCtrl.text.trim(),
                      cost: cost,
                      time: timeCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isNotEmpty
                          ? notesCtrl.text.trim()
                          : null,
                    );
                  },
                  icon: const Icon(Iconsax.send_1, color: AppColors.surface),
                  label: Text(
                    'Send Estimate',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

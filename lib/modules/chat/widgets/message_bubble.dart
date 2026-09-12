import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/message_model.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (message.type == 'system') {
      return _systemBubble();
    }
    if (message.type == 'voice') {
      return _voiceBubble(context);
    }
    if (message.type == 'image') {
      return _imageBubble(context);
    }
    return _textBubble();
  }

  Widget _senderLabel() {
    if (isMe || message.senderName.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: 16.w, bottom: 2.h),
      child: Text(
        message.senderName,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _textBubble() {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _senderLabel(),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            margin: EdgeInsets.only(
              left: isMe ? 60 : 12,
              right: isMe ? 12 : 60,
              top: 3.h,
              bottom: 3.h,
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: AppTextStyles.body2.copyWith(
                    color: isMe ? AppColors.surface : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: AppTextStyles.caption.copyWith(
                        color: isMe ? AppColors.surface.withValues(alpha: 0.7) : AppColors.textHint,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Iconsax.tick_circle,
                        size: 14.w,
                        color: message.read ? AppColors.info : AppColors.surface.withValues(alpha: 0.5),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageBubble(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _senderLabel(),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 240.w),
            margin: EdgeInsets.only(
              left: isMe ? 60 : 12,
              right: isMe ? 12 : 60,
              top: 3.h,
              bottom: 3.h,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: CachedNetworkImage(
                      imageUrl: message.imageUrl ?? '',
                      width: 240.w,
                      height: 180.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SizedBox(
                        height: 180.h,
                        width: 240.w,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) => SizedBox(
                        height: 100.h,
                        child: Center(
                          child: Icon(
                            Iconsax.image,
                            size: 40.w,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (message.content.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    child: Text(
                      message.content,
                      style: AppTextStyles.body2.copyWith(
                        color: isMe ? AppColors.surface : AppColors.textPrimary,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 10.w,
                    bottom: 6.h,
                    left: 10.w,
                  ),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: isMe ? AppColors.surface.withValues(alpha: 0.7) : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _voiceBubble(BuildContext context) {
    final ChatController c = Get.find<ChatController>();
    final duration = message.audioDuration ?? 0;
    final durationStr =
        '${(duration ~/ 60).toString().padLeft(2, '0')}:${(duration % 60).toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _senderLabel(),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            margin: EdgeInsets.only(
              left: isMe ? 60 : 12,
              right: isMe ? 12 : 60,
              top: 3.h,
              bottom: 3.h,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              final isThisPlaying =
                  c.isPlaying.value && c.currentlyPlayingId.value == message.id;
              final progress = isThisPlaying ? c.playbackProgress.value : 0.0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => c.playVoice(message.id, message.audioUrl ?? ''),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.surface.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isThisPlaying ? Iconsax.pause : Iconsax.play,
                        color: isMe ? AppColors.surface : AppColors.primary,
                        size: 22.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24.h,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(20, (i) {
                              final heights = [0.4,0.7,0.5,0.9,0.6,0.8,0.3,1.0,0.5,0.7,0.6,0.9,0.4,0.8,0.5,0.7,0.3,0.6,0.8,0.5];
                              final barProgress = (i + 1) / 20;
                              final isActive = barProgress <= progress;

                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                                  height: 24.h * heights[i],
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? (isMe ? AppColors.surface : AppColors.primary)
                                        : (isMe ? AppColors.surface.withValues(alpha: 0.3) : AppColors.border),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              durationStr,
                              style: AppTextStyles.caption.copyWith(
                                color: isMe ? AppColors.surface.withValues(alpha: 0.7) : AppColors.textHint,
                                fontSize: 10.sp,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(message.timestamp),
                                  style: AppTextStyles.caption.copyWith(
                                    color: isMe ? AppColors.surface.withValues(alpha: 0.7) : AppColors.textHint,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Iconsax.tick_circle,
                                    size: 14.w,
                                    color: message.read ? AppColors.info : AppColors.surface.withValues(alpha: 0.5),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context) {
    if (message.imageUrl == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(imageUrl: message.imageUrl!, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _systemBubble() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 40.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          message.content,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    DateTime dt;
    if (ts is DateTime) {
      dt = ts;
    } else {
      try {
        dt = (ts as dynamic).toDate();
      } catch (_) {
        return '';
      }
    }
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

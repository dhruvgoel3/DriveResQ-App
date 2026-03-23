import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/message_model.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    // System message
    if (message.type == 'system') {
      return _systemBubble();
    }

    // Voice message
    if (message.type == 'voice') {
      return _voiceBubble(context);
    }

    // Image message
    if (message.type == 'image') {
      return _imageBubble(context);
    }

    // Regular text bubble
    return _textBubble();
  }

  // ─── Sender name label (shown for other user's messages) ───
  Widget _senderLabel() {
    if (isMe || message.senderName.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        bottom: 2.h,
      ),
      child: Text(
        message.senderName,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6C63FF),
        ),
      ),
    );
  }

  Widget _textBubble() {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              color: isMe ? const Color(0xFF6C63FF) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isMe ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: isMe ? Colors.white60 : Colors.grey.shade400,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        message.read ? Icons.done_all : Icons.done,
                        size: 14.w,
                        color: message.read
                            ? Colors.lightBlueAccent
                            : Colors.white54,
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
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              color: isMe ? const Color(0xFF6C63FF) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: Image.network(
                      message.imageUrl ?? '',
                      width: 240.w,
                      height: 180.h,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          height: 180.h,
                          width: 240.w,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => SizedBox(
                        height: 100.h,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40.w,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (message.content.isNotEmpty)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Text(
                      message.content,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                Padding(
                  padding:
                      EdgeInsets.only(right: 10.w, bottom: 6.h, left: 10.w),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: isMe ? Colors.white60 : Colors.grey.shade400,
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
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              color: isMe ? const Color(0xFF6C63FF) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() {
              final isThisPlaying = c.isPlaying.value &&
                  c.currentlyPlayingId.value == message.id;
              final progress = isThisPlaying ? c.playbackProgress.value : 0.0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play/Pause button
                  GestureDetector(
                    onTap: () =>
                        c.playVoice(message.id, message.audioUrl ?? ''),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFF6C63FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isThisPlaying ? Icons.pause : Icons.play_arrow,
                        color: isMe ? Colors.white : const Color(0xFF6C63FF),
                        size: 22.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // Waveform progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Waveform bars
                        SizedBox(
                          height: 24.h,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(20, (i) {
                              // Generate pseudo-random heights for waveform look
                              final heights = [
                                0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.3, 1.0, 0.5,
                                0.7, 0.6, 0.9, 0.4, 0.8, 0.5, 0.7, 0.3, 0.6,
                                0.8, 0.5
                              ];
                              final barProgress = (i + 1) / 20;
                              final isActive = barProgress <= progress;

                              return Expanded(
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 0.5.w),
                                  height: 24.h * heights[i],
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? (isMe
                                            ? Colors.white
                                            : const Color(0xFF6C63FF))
                                        : (isMe
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Duration + time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              durationStr,
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: isMe
                                    ? Colors.white60
                                    : Colors.grey.shade500,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(message.timestamp),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    color: isMe
                                        ? Colors.white60
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    message.read
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: 14.w,
                                    color: message.read
                                        ? Colors.lightBlueAccent
                                        : Colors.white54,
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
          child: Image.network(message.imageUrl!, fit: BoxFit.contain),
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          message.content,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
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

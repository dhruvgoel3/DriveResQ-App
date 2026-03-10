import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message_model.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    // System message
    if (message.type == 'system') {
      return _systemBubble();
    }

    // Image message
    if (message.type == 'image') {
      return _imageBubble(context);
    }

    // Regular text bubble
    return _textBubble();
  }

  Widget _textBubble() {
    return Align(
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
          color: isMe ? Color(0xFF6C63FF) : Colors.white,
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
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
    );
  }

  Widget _imageBubble(BuildContext context) {
    return Align(
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
          color: isMe ? Color(0xFF6C63FF) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
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
                      child: Center(
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                child: Text(
                  message.content,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(right: 10.w, bottom: 6.h, left: 10.w),
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

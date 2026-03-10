import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message_model.dart';
import '../controllers/chat_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class PriceQuoteCard extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final ChatController controller;

  PriceQuoteCard({
    super.key,
    required this.message,
    required this.isMe,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final data = message.priceData ?? {};
    final status = data['status'] ?? 'pending';
    final cost = (data['estimatedCost'] as num?)?.toDouble() ?? 0;
    final service = data['service'] ?? '';
    final time = data['estimatedTime'] ?? '';
    final notes = data['notes'] ?? '';
    final parts = (data['parts'] as List?)?.cast<String>() ?? [];
    final counterOffer = (data['counterOffer'] as num?)?.toDouble();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 300.w),
        margin: EdgeInsets.only(
          left: isMe ? 40 : 12,
          right: isMe ? 12 : 40,
          top: 4.h,
          bottom: 4.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _statusColor(status).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.08),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 18.w,
                    color: _statusColor(status),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Service Estimate',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                  Spacer(),
                  _statusBadge(status),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service
                  if (service.isNotEmpty) ...[
                    Text(
                      'Service',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      service,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // Cost
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Cost',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            '₹${cost.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      if (time.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Time',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              time,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Parts
                  if (parts.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Text(
                      'Parts Needed',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: parts
                          .map(
                            (p) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                p,
                                style: GoogleFonts.poppins(fontSize: 11.sp),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  // Notes
                  if (notes.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      notes,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // Counter offer
                  if (counterOffer != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            size: 16.w,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Counter: ₹${counterOffer.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action buttons (driver only, pending only)
                  if (!isMe &&
                      status == 'pending' &&
                      controller.myRole == 'driver') ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text(
                              'Reject',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showNegotiateDialog(cost),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: BorderSide(color: Colors.orange),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text(
                              'Negotiate',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.respondToQuote(
                              message.id,
                              'accepted',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text(
                              'Accept',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog() {
    final reasonCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Decline Estimate',
      content: TextField(
        controller: reasonCtrl,
        decoration: InputDecoration(
          hintText: 'Reason (optional)',
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: 'Decline',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.respondToQuote(
          message.id,
          'rejected',
          reason: reasonCtrl.text.trim().isNotEmpty
              ? reasonCtrl.text.trim()
              : null,
        );
      },
    );
  }

  void _showNegotiateDialog(double originalCost) {
    final priceCtrl = TextEditingController(
      text: originalCost.toStringAsFixed(0),
    );
    final reasonCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Counter Offer',
      content: Column(
        children: [
          Text(
            'Original: ₹${originalCost.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Your price (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: reasonCtrl,
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textConfirm: 'Send',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        Get.back();
        controller.respondToQuote(
          message.id,
          'negotiated',
          counterOffer: double.tryParse(priceCtrl.text),
          reason: reasonCtrl.text.trim().isNotEmpty
              ? reasonCtrl.text.trim()
              : null,
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Color(0xFF4CAF50);
      case 'rejected':
        return Colors.red;
      case 'negotiated':
        return Colors.orange;
      default:
        return Color(0xFF6C63FF);
    }
  }

  Widget _statusBadge(String status) {
    String label;
    switch (status) {
      case 'accepted':
        label = '✅ Accepted';
        break;
      case 'rejected':
        label = '❌ Declined';
        break;
      case 'negotiated':
        label = '💬 Negotiating';
        break;
      default:
        label = '⏳ Pending';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }
}

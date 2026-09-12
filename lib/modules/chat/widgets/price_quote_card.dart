import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message_model.dart';
import '../controllers/chat_controller.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/app_dialogs.dart';

class PriceQuoteCard extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final ChatController controller;

  const PriceQuoteCard({
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
            color: _statusColor(status).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                color: _statusColor(status).withValues(alpha: 0.08),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.receipt_item,
                    size: 18.w,
                    color: _statusColor(status),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Service Estimate',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                  const Spacer(),
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
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    Text(
                      service,
                      style: AppTextStyles.body2.copyWith(
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
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                          Text(
                            '₹${cost.toStringAsFixed(0)}',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (time.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Time',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                            Text(
                              time,
                              style: AppTextStyles.body2.copyWith(
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
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
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
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
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
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.arrow_swap_horizontal,
                            size: 16.w,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Counter: ₹${counterOffer.toStringAsFixed(0)}',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
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
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text(
                              'Reject',
                              style: AppTextStyles.caption.copyWith(
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
                              side: const BorderSide(color: Colors.orange),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text(
                              'Negotiate',
                              style: AppTextStyles.caption.copyWith(
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
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text(
                              'Accept',
                              style: AppTextStyles.caption.copyWith(
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

  void _showRejectDialog() async {
    final reason = await AppDialogs.input(
      title: 'Decline Estimate',
      hint: 'Reason (optional)',
      confirmText: 'Decline',
      cancelText: 'Cancel',
    );
    // If user tapped Decline (even with empty input), respond
    // AppDialogs.input returns null only on cancel
    if (reason != null) {
      controller.respondToQuote(
        message.id,
        'rejected',
        reason: reason.isNotEmpty ? reason : null,
      );
    }
  }

  void _showNegotiateDialog(double originalCost) async {
    final counterPrice = await AppDialogs.input(
      title: 'Counter Offer',
      hint: 'Your price (₹)',
      initialValue: originalCost.toStringAsFixed(0),
      confirmText: 'Send',
      cancelText: 'Cancel',
    );
    if (counterPrice != null) {
      controller.respondToQuote(
        message.id,
        'negotiated',
        counterOffer: double.tryParse(counterPrice),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'negotiated':
        return AppColors.warning;
      default:
        return AppColors.primary;
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
        color: _statusColor(status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }
}

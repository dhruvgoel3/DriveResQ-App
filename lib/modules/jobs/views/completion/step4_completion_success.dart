import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/job_completion_controller.dart';
import '../../services/invoice_generator.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_text_styles.dart';

class CompletionSuccessView extends StatelessWidget {
  const CompletionSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // Success Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.success.withValues(alpha: 0.8), AppColors.success],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Iconsax.check, color: AppColors.surface, size: 64.w),
            ),
          ),

          SizedBox(height: 24.h),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: Column(
              children: [
                Text(
                  'Job Completed! 🎉',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Great work! Job marked as complete.',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 28.h),

          // Summary Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _summaryRow(
                  'Amount Earned',
                  '₹${c.totalAmount.value.toStringAsFixed(0)}',
                  AppColors.success,
                  true,
                ),
                Divider(color: AppColors.border, height: 24.h),
                _summaryRow(
                  'Settlement',
                  c.cashCollected.value
                      ? 'Cash Collected ✓'
                      : 'Settle with driver',
                  AppColors.primary,
                  false,
                ),
                Divider(color: AppColors.border, height: 24.h),
                _summaryRow(
                  'Invoice',
                  c.invoiceNumber.value,
                  AppColors.textPrimary,
                  false,
                ),
                if (c.mechanicRating.value > 0) ...[
                  Divider(color: AppColors.border, height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rating Given',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < c.mechanicRating.value
                                ? Iconsax.star
                                : Iconsax.star,
                            color: AppColors.warning,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: () => _downloadInvoice(c),
              icon: Icon(Iconsax.document_download, size: 20.w),
              label: Text(
                'Download Invoice',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed: () => _shareInvoice(c),
              icon: Icon(Iconsax.share, size: 20.w),
              label: Text(
                'Share Invoice',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                Get.until((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Go to Dashboard',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor, bool bold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _downloadInvoice(JobCompletionController c) async {
    try {
      AppSnackbar.info('Creating PDF invoice', title: 'Generating...');

      final pdfFile = await InvoiceGenerator.generateAndSave(c);

      AppSnackbar.success('Invoice saved to ${pdfFile.path}', title: '✅ Downloaded');
    } catch (e) {
      AppSnackbar.error('Failed to generate invoice: $e');
    }
  }

  void _shareInvoice(JobCompletionController c) async {
    try {
      await InvoiceGenerator.generateAndShare(c);
    } catch (e) {
      AppSnackbar.error('Failed to share: $e');
    }
  }
}

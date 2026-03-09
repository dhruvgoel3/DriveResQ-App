import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';
import '../../services/invoice_generator.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

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
            duration: Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 64.w,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: Column(
              children: [
                Text(
                  'Job Completed! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Great work! Payment has been recorded.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _summaryRow(
                  'Amount Earned',
                  '₹${c.totalAmount.value.toStringAsFixed(0)}',
                  Colors.green.shade700,
                  true,
                ),
                Divider(color: Colors.grey.shade100, height: 24.h),
                _summaryRow(
                  'Payment Method',
                  c.paymentMethod.value,
                  Colors.blue.shade700,
                  false,
                ),
                Divider(color: Colors.grey.shade100, height: 24.h),
                _summaryRow(
                  'Invoice',
                  c.invoiceNumber.value,
                  Colors.purple.shade700,
                  false,
                ),
                if (c.mechanicRating.value > 0) ...[
                  Divider(color: Colors.grey.shade100, height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rating Given',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < c.mechanicRating.value
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Color(0xFFFFB300),
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
              icon: Icon(Icons.download, size: 20.w),
              label: Text(
                'Download Invoice',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
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
              icon: Icon(Icons.share, size: 20.w),
              label: Text(
                'Share Invoice',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF4CAF50),
                side: BorderSide(color: Color(0xFF4CAF50)),
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
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Go to Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
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
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: bold ? 20 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _downloadInvoice(JobCompletionController c) async {
    try {
      Get.snackbar(
        'Generating...',
        'Creating PDF invoice',
        backgroundColor: Colors.blue.shade50,
        colorText: Colors.blue,
      );

      final pdfFile = await InvoiceGenerator.generateAndSave(c);

      Get.snackbar(
        '✅ Downloaded',
        'Invoice saved to ${pdfFile.path}',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate invoice: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  void _shareInvoice(JobCompletionController c) async {
    try {
      await InvoiceGenerator.generateAndShare(c);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';
import '../../services/invoice_generator.dart';

class CompletionSuccessView extends StatelessWidget {
  const CompletionSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Success Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),

          const SizedBox(height: 24),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: Column(
              children: [
                Text(
                  'Job Completed! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Great work! Payment has been recorded.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  Colors.green.shade700,
                  true,
                ),
                Divider(color: Colors.grey.shade100, height: 24),
                _summaryRow(
                  'Payment Method',
                  c.paymentMethod.value,
                  Colors.blue.shade700,
                  false,
                ),
                Divider(color: Colors.grey.shade100, height: 24),
                _summaryRow(
                  'Invoice',
                  c.invoiceNumber.value,
                  Colors.purple.shade700,
                  false,
                ),
                if (c.mechanicRating.value > 0) ...[
                  Divider(color: Colors.grey.shade100, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rating Given',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
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
                            color: const Color(0xFFFFB300),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _downloadInvoice(c),
              icon: const Icon(Icons.download, size: 20),
              label: Text(
                'Download Invoice',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _shareInvoice(c),
              icon: const Icon(Icons.share, size: 20),
              label: Text(
                'Share Invoice',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Get.until((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Go to Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
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
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
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
        duration: const Duration(seconds: 4),
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

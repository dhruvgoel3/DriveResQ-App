import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total amount card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade500, Colors.green.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '₹${c.totalAmount.value.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Including 18% GST',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Payment methods
          Obx(
            () => Column(
              children: [
                _paymentOption(
                  c,
                  'Cash',
                  Icons.money,
                  Colors.green,
                  'Collect cash from driver',
                ),
                const SizedBox(height: 10),
                _paymentOption(
                  c,
                  'UPI',
                  Icons.qr_code,
                  Colors.purple,
                  'GPay, PhonePe, Paytm',
                ),
                const SizedBox(height: 10),
                _paymentOption(
                  c,
                  'Card',
                  Icons.credit_card,
                  Colors.blue,
                  'Coming soon',
                  disabled: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment-specific content
          Obx(() {
            if (c.paymentMethod.value == 'Cash') {
              return _cashSection(c);
            } else if (c.paymentMethod.value == 'UPI') {
              return _upiSection(c);
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 28),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => c.prevStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => c.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Continue to Rating',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _paymentOption(
    JobCompletionController c,
    String method,
    IconData icon,
    Color color,
    String subtitle, {
    bool disabled = false,
  }) {
    final selected = c.paymentMethod.value == method;

    return GestureDetector(
      onTap: disabled ? null : () => c.paymentMethod.value = method,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.shade100
              : selected
              ? color.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (disabled ? Colors.grey : color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: disabled ? Colors.grey : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: disabled ? Colors.grey : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: disabled
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (!disabled)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? color : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: selected ? color : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            if (disabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Soon',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cashSection(JobCompletionController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.payments, size: 48, color: Colors.green.shade400),
          const SizedBox(height: 12),
          Text(
            'Collect Cash Payment',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              'Amount: ₹${c.totalAmount.value.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => CheckboxListTile(
              value: c.paymentCollected.value,
              onChanged: (v) => c.paymentCollected.value = v ?? false,
              title: Text(
                'Payment collected in cash',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeColor: const Color(0xFF4CAF50),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _upiSection(JobCompletionController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_2, size: 48, color: Colors.purple.shade400),
          const SizedBox(height: 12),
          Text(
            'UPI Payment',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: c.transactionIdController,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Transaction ID / UTR Number',
              labelStyle: GoogleFonts.poppins(fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

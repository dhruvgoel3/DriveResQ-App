import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/job_completion_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JobCompletionController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total amount card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade500, Colors.green.shade700],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(
                  () => Text(
                    '₹${c.totalAmount.value.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Including 18% GST',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 28.h),

          Text(
            'Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),

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
                SizedBox(height: 10.h),
                _paymentOption(
                  c,
                  'UPI',
                  Icons.qr_code,
                  Colors.purple,
                  'GPay, PhonePe, Paytm',
                ),
                SizedBox(height: 10.h),
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

          SizedBox(height: 24.h),

          // Payment-specific content
          Obx(() {
            if (c.paymentMethod.value == 'Cash') {
              return _cashSection(c);
            } else if (c.paymentMethod.value == 'UPI') {
              return _upiSection(c);
            }
            return SizedBox.shrink();
          }),

          SizedBox(height: 28.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => c.prevStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => c.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Continue to Rating',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
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
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.shade100
              : selected
              ? color.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: (disabled ? Colors.grey : color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: disabled ? Colors.grey : color,
                size: 24.w,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: disabled ? Colors.grey : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
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
                width: 22.w,
                height: 22.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? color : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: selected ? color : Colors.transparent,
                ),
                child: selected
                    ? Icon(Icons.check, color: Colors.white, size: 14.w)
                    : null,
              ),
            if (disabled)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Soon',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.payments, size: 48.w, color: Colors.green.shade400),
          SizedBox(height: 12.h),
          Text(
            'Collect Cash Payment',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          SizedBox(height: 4.h),
          Obx(
            () => Text(
              'Amount: ₹${c.totalAmount.value.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Obx(
            () => CheckboxListTile(
              value: c.paymentCollected.value,
              onChanged: (v) => c.paymentCollected.value = v ?? false,
              title: Text(
                'Payment collected in cash',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeColor: Color(0xFF4CAF50),
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_2, size: 48.w, color: Colors.purple.shade400),
          SizedBox(height: 12.h),
          Text(
            'UPI Payment',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: c.transactionIdController,
            style: GoogleFonts.poppins(fontSize: 14.sp),
            decoration: InputDecoration(
              labelText: 'Transaction ID / UTR Number',
              labelStyle: GoogleFonts.poppins(fontSize: 13.sp),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.purple.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

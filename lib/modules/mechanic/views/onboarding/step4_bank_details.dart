import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import 'step5_availability.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class Step4BankDetails extends StatelessWidget {
  const Step4BankDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MechanicOnboardingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(c),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(c),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 8.h),
                    _buildSecurityBanner(),
                    SizedBox(height: 28.h),
                    _buildField(
                      c.accountHolderController,
                      'Account Holder Name *',
                      'Enter account holder name',
                      Iconsax.user,
                    ),
                    SizedBox(height: 20.h),
                    _buildField(
                      c.accountNumberController,
                      'Account Number *',
                      'Enter account number',
                      Iconsax.bank,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      obscure: true,
                    ),
                    SizedBox(height: 20.h),
                    _buildField(
                      c.confirmAccountController,
                      'Re-enter Account Number *',
                      'Confirm account number',
                      Iconsax.bank,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 20.h),
                    _buildField(
                      c.ifscController,
                      'IFSC Code *',
                      'e.g. SBIN0001234',
                      Iconsax.code,
                      caps: true,
                    ),
                    SizedBox(height: 20.h),
                    _buildField(
                      c.bankNameController,
                      'Bank Name *',
                      'Enter bank name',
                      Iconsax.wallet,
                    ),
                    SizedBox(height: 20.h),
                    _buildField(
                      c.upiController,
                      'UPI ID (Optional)',
                      'e.g. name@upi',
                      Iconsax.card,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            _buildContinueButton(c),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(MechanicOnboardingController c) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left_2, color: Colors.black87, size: 20.w),
        onPressed: () {
          c.currentStep.value = 3;
          Get.back();
        },
      ),
      title: Text(
        'Mechanic Registration',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressBar(MechanicOnboardingController c) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${c.currentStep.value} of 6',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
                Text(
                  'Bank Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: c.currentStep.value / 6,
                minHeight: 6.h,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Details',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'For secure payment processing',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Iconsax.shield, color: Colors.blue.shade700, size: 22.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Your bank details are encrypted and stored securely',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool obscure = false,
    bool caps = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: type,
          inputFormatters: formatters,
          obscureText: obscure,
          textCapitalization: caps
              ? TextCapitalization.characters
              : TextCapitalization.none,
          cursorColor: const Color(0xFFFF9800),
          style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: const Color(0xFFFF9800), size: 22.w),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(MechanicOnboardingController c) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            c.nextStep();
            if (c.currentStep.value == 5) {
              Get.to(() => Step5Availability());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF9800),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

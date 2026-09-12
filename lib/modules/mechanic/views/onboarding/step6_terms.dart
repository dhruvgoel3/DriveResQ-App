import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class Step6Terms extends StatelessWidget {
  const Step6Terms({super.key});

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
                    SizedBox(height: 24.h),
                    _buildTermsContent(),
                    SizedBox(height: 28.h),
                    _buildCheckboxes(c),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(c),
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
          c.currentStep.value = 5;
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
                    color: const Color(0xFFFF9800),
                  ),
                ),
                Text(
                  'Terms & Agreement',
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
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF9800),
                ),
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
          'Terms & Agreement',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Please read and accept our policies',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsContent() {
    return Container(
      height: 280.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        child: Text(
          '''TERMS AND CONDITIONS FOR DriveResQ MECHANIC PARTNERS

1. SERVICE AGREEMENT
By registering as a mechanic partner on DriveResQ, you agree to provide roadside assistance services to drivers in need. You are responsible for maintaining the quality and safety of all services you provide.

2. VERIFICATION PROCESS
All mechanic partners must undergo a verification process. DriveResQ reserves the right to verify your identity, qualifications, and business credentials before granting platform access.

3. SERVICE STANDARDS
You agree to:
• Respond to service requests promptly
• Maintain professional conduct at all times
• Use genuine parts and follow industry-standard practices
• Provide honest assessments and fair pricing
• Carry valid insurance and required licenses

4. PAYMENT TERMS
• Payments will be processed within 24-48 hours of service completion
• DriveResQ charges a platform fee of 10% on each transaction
• All pricing must be transparent and disclosed before service begins

5. LIABILITY
• You are solely responsible for the quality of your services
• DriveResQ acts only as a platform and is not liable for service outcomes
• Proper tools, safety equipment, and insurance must be maintained

6. ACCOUNT SUSPENSION
DriveResQ may suspend accounts for:
• Poor customer ratings
• Policy violations
• Fraudulent activity
• Failure to maintain valid documents

7. DATA PRIVACY
Your personal and financial data is protected under our privacy policy. We collect and use data solely for platform operations and compliance requirements.

8. MODIFICATION OF TERMS
DriveResQ reserves the right to modify these terms at any time. Continued use of the platform constitutes acceptance of modified terms.''',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            height: 1.8,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxes(MechanicOnboardingController c) {
    return Column(
      children: [
        Obx(
          () => _checkTile(
            value: c.agreeTerms.value,
            onChanged: (v) => c.agreeTerms.value = v ?? false,
            text: 'I agree to the Terms and Conditions',
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => _checkTile(
            value: c.agreeVerification.value,
            onChanged: (v) => c.agreeVerification.value = v ?? false,
            text: 'I consent to background verification',
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => _checkTile(
            value: c.agreePrivacy.value,
            onChanged: (v) => c.agreePrivacy.value = v ?? false,
            text: "I accept DriveResQ's Privacy Policy",
          ),
        ),
      ],
    );
  }

  Widget _checkTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFFFF9800).withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: value
                ? const Color(0xFFFF9800).withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: value ? const Color(0xFFFF9800) : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: value ? const Color(0xFFFF9800) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: value
                  ? Icon(Iconsax.tick_circle, size: 16.w, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(MechanicOnboardingController c) {
    return Obx(() {
      final allChecked =
          c.agreeTerms.value &&
          c.agreeVerification.value &&
          c.agreePrivacy.value;
      return Container(
        padding: EdgeInsets.all(24.w),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: allChecked && !c.isLoading.value
                ? () => c.submitOnboarding()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: c.isLoading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Obx(
                        () => Text(
                          'Uploading ${(c.uploadProgress.value * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Submit Application',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}

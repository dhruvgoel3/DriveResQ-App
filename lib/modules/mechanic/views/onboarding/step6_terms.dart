import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/onboarding_controller.dart';

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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildTermsContent(),
                    const SizedBox(height: 28),
                    _buildCheckboxes(c),
                    const SizedBox(height: 40),
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
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black87,
          size: 20,
        ),
        onPressed: () {
          c.currentStep.value = 5;
          Get.back();
        },
      ),
      title: Text(
        'Mechanic Registration',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressBar(MechanicOnboardingController c) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${c.currentStep.value} of 6',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                Text(
                  'Terms & Agreement',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: c.currentStep.value / 6,
                minHeight: 6,
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
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Please read and accept our policies',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildTermsContent() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
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
            fontSize: 13,
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
        const SizedBox(height: 12),
        Obx(
          () => _checkTile(
            value: c.agreeVerification.value,
            onChanged: (v) => c.agreeVerification.value = v ?? false,
            text: 'I consent to background verification',
          ),
        ),
        const SizedBox(height: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFFFF9800).withOpacity(0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? const Color(0xFFFF9800).withOpacity(0.4)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFFFF9800) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? const Color(0xFFFF9800) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
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
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
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
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: c.isLoading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(
                        () => Text(
                          'Uploading ${(c.uploadProgress.value * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Submit Application',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}

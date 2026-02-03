  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:get/get.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:pinput/pinput.dart';
  import '../controllers/auth_controller.dart';

  class OTPVerificationView extends StatelessWidget {
    const OTPVerificationView({super.key});

    @override
    Widget build(BuildContext context) {
      final controller = Get.find<AuthController>();

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Verify your",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  "Phone Number",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Code sent to +91 ${controller.phoneController.text}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 50),

                // OTP Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      size: 60,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input
                Center(
                  child: Pinput(
                    controller: controller.otpController,
                    length: 6,
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 60,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 60,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6C63FF),
                          width: 2,
                        ),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 50,
                      height: 60,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF6C63FF)),
                      ),
                    ),
                    onCompleted: (_) => controller.verifyOTP(),
                  ),
                ),

                const SizedBox(height: 30),

                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: controller.resendOTP,
                    child: Text(
                      "Didn't receive code? Resend",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Verify button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Verify & Continue",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
  }

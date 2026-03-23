import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../controllers/auth_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

class OTPVerificationView extends StatefulWidget {
  const OTPVerificationView({super.key});

  @override
  State<OTPVerificationView> createState() => _OTPVerificationViewState();
}

class _OTPVerificationViewState extends State<OTPVerificationView>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF6C63FF);
  static const _red = Color(0xFFF44336);

  bool _hasError = false;
  String? _errorMessage;

  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation =
        TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: const Offset(0.03, 0)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(0.03, 0),
              end: const Offset(-0.03, 0),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: const Offset(-0.03, 0),
              end: const Offset(0.02, 0),
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0.02, 0), end: Offset.zero),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onVerifyError() {
    setState(() {
      _hasError = true;
      _errorMessage = 'Invalid OTP. Please try again.';
    });
    _shakeController.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final defaultTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _primary, width: 2),
      ),
    );

    final submittedTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _primary),
      ),
    );

    final errorTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: _red,
      ),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _red, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      // Header
                      Text(
                        "Verify your",
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        "Phone Number",
                        style: GoogleFonts.poppins(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Code sent to +91 ${controller.phoneController.text}",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),

                      SizedBox(height: 36.h),

                      // OTP Icon
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: (_hasError ? _red : _primary).withOpacity(
                              0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _hasError
                                ? Iconsax.close_circle
                                : Iconsax.mobile,
                            size: 48.w,
                            color: _hasError ? _red : _primary,
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // OTP Input with shake
                      Center(
                        child: SlideTransition(
                          position: _shakeAnimation,
                          child: Pinput(
                            controller: controller.otpController,
                            length: 6,
                            defaultPinTheme: _hasError
                                ? errorTheme
                                : defaultTheme,
                            focusedPinTheme: focusedTheme,
                            submittedPinTheme: _hasError
                                ? errorTheme
                                : submittedTheme,
                            onChanged: (_) {
                              if (_hasError) {
                                setState(() {
                                  _hasError = false;
                                  _errorMessage = null;
                                });
                              }
                            },
                            onCompleted: (_) async {
                              try {
                                await controller.verifyOTP();
                              } catch (_) {
                                _onVerifyError();
                              }
                            },
                          ),
                        ),
                      ),

                      // Inline error
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _errorMessage != null
                            ? Padding(
                                padding: EdgeInsets.only(top: 12.h),
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _red.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.close_circle,
                                          color: _red,
                                          size: 16.w,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          _errorMessage!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            color: _red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      SizedBox(height: 24.h),

                      // Resend OTP
                      Center(
                        child: TextButton(
                          onPressed: controller.resendOTP,
                          child: Text(
                            "Didn't receive code? Resend",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: _primary,
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
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    try {
                                      await controller.verifyOTP();
                                    } catch (_) {
                                      _onVerifyError();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Verify & Continue",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: bottom > 0 ? 12 : 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

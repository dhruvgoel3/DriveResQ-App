import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import '../../controller/mechanic_controller.dart';
import '../../../jobs/controllers/job_completion_controller.dart';
import '../../../jobs/views/job_completion_page.dart';

/// Bottom sheet dialog for mechanic to enter verification code before completing a job
class CompleteJobVerificationDialog extends StatefulWidget {
  const CompleteJobVerificationDialog({super.key});

  @override
  State<CompleteJobVerificationDialog> createState() =>
      _CompleteJobVerificationDialogState();
}

class _CompleteJobVerificationDialogState
    extends State<CompleteJobVerificationDialog>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isVerifying = false;
  String? _errorMessage;
  bool _isSuccess = false;

  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  static const _primary = Color(0xFF6C63FF);
  static const _green = Color(0xFF4CAF50);

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
    _pinController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _pinController.text;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final controller = Get.find<MechanicController>();

    // Save job data BEFORE verification (since status change may clear activeJob)
    final jobData = controller.activeJob.value != null
        ? Map<String, dynamic>.from(controller.activeJob.value!)
        : null;
    final savedJobId = jobData?['id'];

    final result = await controller.verifyAndCompleteJob(code);

    if (!mounted) return;

    if (result == null) {
      // Success — show checkmark, then navigate to job completion page
      setState(() {
        _isSuccess = true;
        _isVerifying = false;
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        Get.back(); // Close dialog

        // Navigate to Job Completion Page
        if (jobData != null) {
          // Register controller if not already
          if (!Get.isRegistered<JobCompletionController>()) {
            Get.put(JobCompletionController());
          } else {
            // Reset if already registered
            final existingCtrl = Get.find<JobCompletionController>();
            existingCtrl.currentStep.value = 0;
            existingCtrl.jobData.value = null;
          }

          Get.to(
            () => const JobCompletionPage(),
            arguments: {'job': jobData, 'jobId': savedJobId},
          );
        }
      }
    } else {
      // Error — shake and show message
      setState(() {
        _isVerifying = false;
        _errorMessage = result;
      });
      _shakeController.forward(from: 0);
      _pinController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: _isSuccess ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: _green.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.tick_circle, color: Colors.white, size: 28.w),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verification Successful",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Navigating to job summary...",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              LinearProgressIndicator(
                backgroundColor: _green.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(_green),
                minHeight: 4.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildForm() {
    final defaultTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _primary, width: 2),
      ),
    );

    final errorTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red, width: 2),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 24.h),

        // Title
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Iconsax.verify, color: _primary, size: 32.w),
        ),
        SizedBox(height: 16.h),
        Text(
          "Enter Verification Code",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Ask the driver for the 6-digit code\nto confirm job completion",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        SizedBox(height: 28.h),

        // PIN input with shake animation
        SlideTransition(
          position: _shakeAnimation,
          child: Pinput(
            controller: _pinController,
            focusNode: _focusNode,
            length: 6,
            defaultPinTheme: _errorMessage != null ? errorTheme : defaultTheme,
            focusedPinTheme: focusedTheme,
            submittedPinTheme: _errorMessage != null
                ? errorTheme
                : defaultTheme.copyWith(
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _primary),
                    ),
                  ),
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
            onCompleted: (_) => _verify(),
          ),
        ),

        // Error message
        if (_errorMessage != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.close_circle, color: Colors.red, size: 18.w),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 24.h),

        // Verify button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verify,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: _isVerifying
                ? SizedBox(
                    height: 22.h,
                    width: 22.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    "Verify & Complete",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),

        SizedBox(
          height: MediaQuery.of(context).viewInsets.bottom > 0 ? 12.h : 16.h,
        ),
      ],
    );
  }
}

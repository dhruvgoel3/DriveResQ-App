import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/form_validators.dart';

class PhoneNumberView extends StatefulWidget {
  const PhoneNumberView({super.key});

  @override
  State<PhoneNumberView> createState() => _PhoneNumberViewState();
}

class _PhoneNumberViewState extends State<PhoneNumberView> {
  static const _primary = Color(0xFF6C63FF);
  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFF44336);

  String? _phoneError;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<AuthController>();
    controller.phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    Get.find<AuthController>().phoneController.removeListener(_onPhoneChanged);
    super.dispose();
  }

  void _onPhoneChanged() {
    final text = Get.find<AuthController>().phoneController.text;
    if (!_hasInteracted && text.length >= 3) {
      _hasInteracted = true;
    }
    if (_hasInteracted) {
      setState(() {
        _phoneError = FormValidators.validatePhone(text);
      });
    }
  }

  bool get _isPhoneValid =>
      _hasInteracted &&
      _phoneError == null &&
      Get.find<AuthController>().phoneController.text.isNotEmpty;

  Color get _borderColor {
    if (_hasInteracted && _phoneError != null) return _red;
    if (_isPhoneValid) return _green;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

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
                        "Enter your",
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
                        "We'll send you a verification code",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Role badge
                      Obx(
                        () => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: controller.selectedRole.value == 'driver'
                                ? Colors.blue.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.selectedRole.value == 'driver'
                                    ? Iconsax.car
                                    : Iconsax.setting_2,
                                size: 16.w,
                                color: controller.selectedRole.value == 'driver'
                                    ? Colors.blue
                                    : Colors.orange,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                controller.selectedRole.value == 'driver'
                                    ? 'Driver'
                                    : 'Mechanic',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      controller.selectedRole.value == 'driver'
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Phone input with inline validation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: _borderColor,
                            width: _hasInteracted ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: _primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                "+91",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                controller: controller.phoneController,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.phone,
                                maxLength: 15,
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d+]'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  hintText: "Phone Number",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  counterText: "",
                                  contentPadding: EdgeInsets.zero,
                                  isCollapsed: true,
                                  filled: false,
                                  suffixIcon: _buildSuffixIcon(),
                                  suffixIconConstraints: BoxConstraints(
                                    minWidth: 28.w,
                                    minHeight: 28.h,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Inline error text
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _hasInteracted && _phoneError != null
                            ? Padding(
                                padding: EdgeInsets.only(top: 8.h, left: 4.w),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.close_circle,
                                      color: _red,
                                      size: 14.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        _phoneError!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: _red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const Spacer(),

                      // Send OTP button — disabled until valid
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed:
                                controller.isLoading.value || !_isPhoneValid
                                ? null
                                : controller.sendOTP,
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
                                    "Send OTP",
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

  Widget? _buildSuffixIcon() {
    if (!_hasInteracted) return null;
    if (_isPhoneValid) {
      return Padding(
        padding: EdgeInsets.only(right: 4.w),
        child: Icon(Iconsax.tick_circle, color: _green, size: 22.w),
      );
    }
    if (_phoneError != null) {
      return Padding(
        padding: EdgeInsets.only(right: 4.w),
        child: Icon(Iconsax.close_square, color: _red, size: 22.w),
      );
    }
    return null;
  }
}

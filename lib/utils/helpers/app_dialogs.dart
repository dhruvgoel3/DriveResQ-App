import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// Centralized, premium dialog utility for the app.
///
/// Usage:
/// ```dart
/// final confirmed = await AppDialogs.confirm(
///   title: 'Logout',
///   message: 'Are you sure?',
///   confirmText: 'Yes, Logout',
///   icon: Iconsax.logout,
///   iconColor: Colors.red,
/// );
///
/// AppDialogs.loading(message: 'Please wait...');
/// ```
class AppDialogs {
  AppDialogs._();

  /// Premium **confirmation dialog** with animated icon & gradient buttons.
  ///
  /// Returns `true` if confirmed, `false` or `null` if cancelled.
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Iconsax.warning_2,
    Color iconColor = AppColors.error,
    bool isDangerous = false,
  }) async {
    final accentColor = isDangerous ? AppColors.error : AppColors.primary;

    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated Icon ──
                Container(
                  width: 68.w,
                  height: 68.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withValues(alpha: 0.15),
                        iconColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 32.w, color: iconColor),
                ),

                SizedBox(height: 20.h),

                // ── Title ──
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                    decoration: TextDecoration.none,
                  ),
                ),

                SizedBox(height: 8.h),

                // ── Message ──
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Action Buttons ──
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(result: false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Text(
                              cancelText,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Confirm
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(result: true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            gradient: LinearGradient(
                              colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              confirmText,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Premium **loading dialog** with animated spinner & gradient glow.
  ///
  /// Call `Get.back()` to dismiss.
  static void loading({String message = 'Please wait...'}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            width: 240.w,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinner with glow
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  'This may take a moment',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textHint,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Premium **input dialog** with a single text field.
  ///
  /// Returns the entered text, or `null` if cancelled.
  static Future<String?> input({
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
    IconData icon = Iconsax.edit_2,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await Get.dialog<String?>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Icon(icon, size: 26.w, color: AppColors.primary),
                ),

                SizedBox(height: 16.h),

                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Text Field ──
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint ?? 'Enter here...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Actions ──
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(result: null),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            color: Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Text(
                              cancelText,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final text = controller.text.trim();
                          Get.back(result: text.isEmpty ? null : text);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              confirmText,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    controller.dispose();
    return result;
  }
}

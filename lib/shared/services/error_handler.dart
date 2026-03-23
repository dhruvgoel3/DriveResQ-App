import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_spacing.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';

/// Centralized error handler — parse errors and show friendly messages.
class ErrorHandler {
  static void handle(
    dynamic error, {
    VoidCallback? onRetry,
    String? fallbackMessage,
  }) {
    final parsed = _parse(error);
    showErrorSheet(
      title: parsed.title,
      message: parsed.message,
      icon: parsed.icon,
      color: parsed.color,
      onRetry: onRetry,
    );
  }

  static _ParsedError _parse(dynamic error) {
    final msg = error.toString().toLowerCase();

    // Network
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('timeout') ||
        msg.contains('handshake')) {
      return _ParsedError(
        title: 'Connection Lost',
        message: 'Please check your internet connection and try again.',
        icon: Iconsax.wifi,
        color: AppColors.warning,
      );
    }

    // Firebase permission
    if (msg.contains('permission-denied') || msg.contains('unauthorized')) {
      return _ParsedError(
        title: 'Access Denied',
        message:
            "You don't have permission to do this. Please contact support.",
        icon: Iconsax.lock,
        color: AppColors.error,
      );
    }

    // Firebase not found
    if (msg.contains('not-found') || msg.contains('no document')) {
      return _ParsedError(
        title: 'Not Found',
        message: "The information you're looking for doesn't exist.",
        icon: Iconsax.search_normal,
        color: AppColors.info,
      );
    }

    // Firebase index / precondition
    if (msg.contains('failed-precondition') || msg.contains('index')) {
      return _ParsedError(
        title: 'Configuration Issue',
        message: 'There is a temporary issue. Please try again.',
        icon: Iconsax.setting_2,
        color: AppColors.warning,
      );
    }

    // Location
    if (msg.contains('location') || msg.contains('gps')) {
      return _ParsedError(
        title: 'Location Required',
        message: 'Please enable location services to continue.',
        icon: Iconsax.location_slash,
        color: AppColors.secondary,
      );
    }

    // Image / upload
    if (msg.contains('file too large') || msg.contains('upload')) {
      return _ParsedError(
        title: 'Upload Failed',
        message:
            "Couldn't upload the file. Check your connection and try again.",
        icon: Iconsax.cloud_cross,
        color: AppColors.error,
      );
    }

    // Rate limit
    if (msg.contains('too-many-requests') || msg.contains('rate')) {
      return _ParsedError(
        title: 'Too Many Requests',
        message: 'Please wait a moment before trying again.',
        icon: Iconsax.info_circle,
        color: AppColors.warning,
      );
    }

    // Session / auth
    if (msg.contains('unauthenticated') ||
        msg.contains('session') ||
        msg.contains('token')) {
      return _ParsedError(
        title: 'Session Expired',
        message: 'Please log in again to continue.',
        icon: Iconsax.lock,
        color: AppColors.info,
      );
    }

    // Generic fallback
    return _ParsedError(
      title: 'Something Went Wrong',
      message: 'An unexpected error occurred. Please try again.',
      icon: Iconsax.close_circle,
      color: AppColors.error,
    );
  }

  // ── Snackbar shorthand ──
  static void showSnackbar(
    String message, {
    bool isError = true,
    VoidCallback? onRetry,
  }) {
    Get.snackbar(
      isError ? 'Error' : 'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppColors.error : AppColors.info,
      colorText: Colors.white,
      icon: Icon(
        isError ? Iconsax.close_circle : Iconsax.info_circle,
        color: Colors.white,
      ),
      margin: EdgeInsets.all(12.w),
      borderRadius: AppRadius.medium,
      duration: Duration(seconds: 4),
      mainButton: onRetry != null
          ? TextButton(
              onPressed: () {
                Get.closeCurrentSnackbar();
                onRetry();
              },
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  // ── Success snackbar ──
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: Icon(Iconsax.tick_circle, color: Colors.white),
      margin: EdgeInsets.all(12.w),
      borderRadius: AppRadius.medium,
      duration: Duration(seconds: 3),
    );
  }

  // ── Bottom sheet error dialog ──
  static void showErrorSheet({
    required String title,
    required String message,
    required IconData icon,
    Color color = AppColors.error,
    VoidCallback? onRetry,
  }) {
    Get.bottomSheet(
      _ErrorSheet(
        title: title,
        message: message,
        icon: icon,
        color: color,
        onRetry: onRetry,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }
}

class _ParsedError {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _ParsedError({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

/// Beautiful error bottom sheet with icon, message, and retry action.
class _ErrorSheet extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onRetry;

  const _ErrorSheet({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24.h),

          // Icon
          Container(
            width: 72.w,
            height: 72.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 36.w, color: color),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onRetry!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Standalone error widget for inline display (not bottom sheet).
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onRetry;

  ErrorStateWidget({
    super.key,
    this.title = 'Something Went Wrong',
    this.message = 'An unexpected error occurred.',
    this.icon = Iconsax.close_circle,
    this.color = AppColors.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 40.w, color: color),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Iconsax.refresh, size: 18.w),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

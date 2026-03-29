import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/utils/helpers/app_snackbar.dart';

/// A centralized Error Handler to parse and display user-friendly error messages.
///
/// This service maps technical exceptions (Firebase, Network, etc.) to
/// human-readable titles and descriptions, displaying them via Snackbars or BottomSheets.
class ErrorHandler {
  /// Main entry point to handle any [error].
  ///
  /// Optionally takes an [onRetry] callback to allow users to attempt the action again.
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

  /// Categorizes the raw [error] into a [_ParsedError] object.
  static _ParsedError _parse(dynamic error) {
    final msg = error.toString().toLowerCase();

    // 🌐 Network & Connectivity
    if (RegExp(r'network|socket|connection|timeout|handshake').hasMatch(msg)) {
      return _ParsedError(
        title: 'Connection Issue',
        message:
            'We couldn\'t reach our servers. Please check your internet connection.',
        icon: Iconsax.wifi,
        color: AppColors.warning,
      );
    }

    // 🔒 Permissions & Auth
    if (RegExp(r'permission-denied|unauthorized|forbidden').hasMatch(msg)) {
      return _ParsedError(
        title: 'Access Denied',
        message:
            'You don\'t have the necessary permissions to perform this action.',
        icon: Iconsax.lock,
        color: AppColors.error,
      );
    }

    // 🔎 Resource Not Found
    if (RegExp(r'not-found|no document').hasMatch(msg)) {
      return _ParsedError(
        title: 'Not Found',
        message: 'The requested information is missing or has been removed.',
        icon: Iconsax.search_normal,
        color: AppColors.info,
      );
    }

    // 📍 Location Services
    if (RegExp(r'location|gps|geolocator').hasMatch(msg)) {
      return _ParsedError(
        title: 'Location Required',
        message:
            'Please enable GPS and grant location permissions to continue.',
        icon: Iconsax.location_slash,
        color: AppColors.secondary,
      );
    }

    // ☁️ Storage & Uploads
    if (RegExp(r'upload|storage|file too large').hasMatch(msg)) {
      return _ParsedError(
        title: 'Upload Failed',
        message: 'Could not upload files. Ensure you have a stable connection.',
        icon: Iconsax.cloud_cross,
        color: AppColors.error,
      );
    }

    // ⏳ Rate Limiting
    if (RegExp(r'too-many-requests|rate-limit').hasMatch(msg)) {
      return _ParsedError(
        title: 'Slow Down',
        message: 'Too many attempts. Please wait a few moments and try again.',
        icon: Iconsax.info_circle,
        color: AppColors.warning,
      );
    }

    // 🔑 Session Management
    if (RegExp(r'unauthenticated|session|token|auth').hasMatch(msg)) {
      return _ParsedError(
        title: 'Session Expired',
        message: 'Your login session has expired. Please log in again.',
        icon: Iconsax.lock,
        color: AppColors.info,
      );
    }

    // 🔧 Default Fallback
    return _ParsedError(
      title: 'Unexpected Error',
      message: 'Something went wrong on our end. Please try again soon.',
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
    if (isError) {
      AppSnackbar.error(message);
    } else {
      AppSnackbar.info(message);
    }
  }

  // ── Success snackbar ──
  static void showSuccess(String message) {
    AppSnackbar.success(message);
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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

  const ErrorStateWidget({
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

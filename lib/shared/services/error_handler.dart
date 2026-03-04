import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driveresq_app/theme/app_colors.dart';
import 'package:driveresq_app/theme/app_spacing.dart';

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
        icon: Icons.wifi_off_rounded,
        color: AppColors.warning,
      );
    }

    // Firebase permission
    if (msg.contains('permission-denied') || msg.contains('unauthorized')) {
      return _ParsedError(
        title: 'Access Denied',
        message:
            "You don't have permission to do this. Please contact support.",
        icon: Icons.lock_outline,
        color: AppColors.error,
      );
    }

    // Firebase not found
    if (msg.contains('not-found') || msg.contains('no document')) {
      return _ParsedError(
        title: 'Not Found',
        message: "The information you're looking for doesn't exist.",
        icon: Icons.search_off_rounded,
        color: AppColors.info,
      );
    }

    // Firebase index / precondition
    if (msg.contains('failed-precondition') || msg.contains('index')) {
      return _ParsedError(
        title: 'Configuration Issue',
        message: 'There is a temporary issue. Please try again.',
        icon: Icons.settings_outlined,
        color: AppColors.warning,
      );
    }

    // Location
    if (msg.contains('location') || msg.contains('gps')) {
      return _ParsedError(
        title: 'Location Required',
        message: 'Please enable location services to continue.',
        icon: Icons.location_off_rounded,
        color: AppColors.secondary,
      );
    }

    // Image / upload
    if (msg.contains('file too large') || msg.contains('upload')) {
      return _ParsedError(
        title: 'Upload Failed',
        message:
            "Couldn't upload the file. Check your connection and try again.",
        icon: Icons.cloud_off_rounded,
        color: AppColors.error,
      );
    }

    // Rate limit
    if (msg.contains('too-many-requests') || msg.contains('rate')) {
      return _ParsedError(
        title: 'Too Many Requests',
        message: 'Please wait a moment before trying again.',
        icon: Icons.front_hand_outlined,
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
        icon: Icons.lock_clock_outlined,
        color: AppColors.info,
      );
    }

    // Generic fallback
    return _ParsedError(
      title: 'Something Went Wrong',
      message: 'An unexpected error occurred. Please try again.',
      icon: Icons.error_outline_rounded,
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
        isError ? Icons.error_outline : Icons.info_outline,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(12),
      borderRadius: AppRadius.medium,
      duration: const Duration(seconds: 4),
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
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: AppRadius.medium,
      duration: const Duration(seconds: 3),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onRetry!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
    this.icon = Icons.error_outline_rounded,
    this.color = AppColors.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

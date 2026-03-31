import 'package:flashy_flushbar/flashy_flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

/// Centralized, premium snackbar utility using FlashyFlushbar.
///
/// Usage:
/// ```dart
/// AppSnackbar.success('Profile updated');
/// AppSnackbar.error('Failed to save', title: 'Oops');
/// AppSnackbar.warning('Check your input');
/// AppSnackbar.info('New update available');
/// ```
class AppSnackbar {
  AppSnackbar._();

  // ── Color Palette ──
  static const _successStart = Color(0xFF00C853);
  static const _successEnd = Color(0xFF69F0AE);
  static const _errorStart = Color(0xFFFF1744);
  static const _errorEnd = Color(0xFFFF8A80);
  static const _warningStart = Color(0xFFFF9100);
  static const _warningEnd = Color(0xFFFFD180);
  static const _infoStart = Color(0xFF2979FF);
  static const _infoEnd = Color(0xFF82B1FF);

  // ── Public API ──

  /// Show a **success** flushbar (green).
  static void success(String message, {String? title}) {
    _show(
      message: message,
      title: title ?? 'Success',
      icon: Iconsax.tick_circle,
      gradientStart: _successStart,
      gradientEnd: _successEnd,
      iconBgColor: const Color(0xFF00C853),
    );
  }

  /// Show an **error** flushbar (red).
  static void error(String message, {String? title}) {
    _show(
      message: message,
      title: title ?? 'Error',
      icon: Iconsax.close_circle,
      gradientStart: _errorStart,
      gradientEnd: _errorEnd,
      iconBgColor: const Color(0xFFFF1744),
    );
  }

  /// Show a **warning** flushbar (amber/orange).
  static void warning(String message, {String? title}) {
    _show(
      message: message,
      title: title ?? 'Warning',
      icon: Iconsax.warning_2,
      gradientStart: _warningStart,
      gradientEnd: _warningEnd,
      iconBgColor: const Color(0xFFFF9100),
    );
  }

  /// Show an **info** flushbar (blue).
  static void info(String message, {String? title}) {
    _show(
      message: message,
      title: title ?? 'Info',
      icon: Iconsax.info_circle,
      gradientStart: _infoStart,
      gradientEnd: _infoEnd,
      iconBgColor: const Color(0xFF2979FF),
    );
  }

  // ── Internal ──

  static void _show({
    required String message,
    required String title,
    required IconData icon,
    required Color gradientStart,
    required Color gradientEnd,
    required Color iconBgColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    FlashyFlushbar(
      duration: duration,
      backgroundColor: Colors.white,
      isDismissible: true,
      customWidget: Row(
        children: [
          // Icon/Leading
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  gradientStart,
                  gradientEnd.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientStart.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),

          // Content (Title + Message)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: gradientStart,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Close Button
          GestureDetector(
            onTap: () => FlashyFlushbar.cancel(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade500,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    ).show();
  }
}

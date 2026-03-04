import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// DriveResQ typography system — all text styles in one place.
class AppTextStyles {
  AppTextStyles._();

  // ── Headings ──
  static final h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static final h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static final h3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static final h4 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ── Body ──
  static final body1 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static final body2 = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ── Utility ──
  static final caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static final button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static final label = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static final subtitle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );
}

import 'package:flutter/material.dart';

/// DriveResQ color palette — single source of truth for all colors.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF5A52D5);
  static const primaryLight = Color(0xFF8B7CFF);
  static const secondary = Color(0xFFFF9800);
  static const secondaryDark = Color(0xFFF57C00);
  static const accent = Color(0xFF00BCD4);

  // ── Semantic ──
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // ── Grayscale ──
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE0E0E0);
  static const disabled = Color(0xFFBDBDBD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFF9E9E9E);

  // ── Dark Mode ──
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceVariant = Color(0xFF2C2C2C);
  static const darkPrimary = Color(0xFFBB86FC);
  static const darkSecondary = Color(0xFF03DAC6);
  static const darkError = Color(0xFFCF6679);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFB3B3B3);

  // ── Role-based ──
  static const driverPrimary = Color(0xFF2196F3);
  static const driverAccent = Color(0xFF00BCD4);
  static const mechanicPrimary = Color(0xFFFF9800);
  static const mechanicAccent = Color(0xFFFF5722);

  // ── Gradients ──
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const splashGradient = LinearGradient(
    colors: [primary, Color(0xFF5B52E5), Color(0xFF3D35C5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

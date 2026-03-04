import 'package:flutter/material.dart';

/// DriveResQ spacing, radius, and shadow tokens.
class AppSpacing {
  AppSpacing._();

  // ── Spacing (8px grid) ──
  static const double xxs = 4;
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // ── Padding helpers ──
  static const pagePadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  static const cardPadding = EdgeInsets.all(16);
  static const sectionPadding = EdgeInsets.symmetric(vertical: 24);
}

/// Border radius tokens.
class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xLarge = 24;
  static const double full = 999;

  static final smallAll = BorderRadius.circular(small);
  static final mediumAll = BorderRadius.circular(medium);
  static final largeAll = BorderRadius.circular(large);
  static final xLargeAll = BorderRadius.circular(xLarge);
  static final fullAll = BorderRadius.circular(full);
}

/// Shadow elevation tokens.
class AppShadows {
  AppShadows._();

  static final level1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final level2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final level3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static final level4 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

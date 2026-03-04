import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// DriveResQ theme — light and dark ThemeData.
class AppTheme {
  AppTheme._();

  // ══════════════════════════════
  //  LIGHT THEME
  // ══════════════════════════════
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeAll,
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Input — intentionally minimal so per-screen styles are preserved
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.disabled,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        elevation: 8,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.5),
        thickness: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
        backgroundColor: AppColors.surface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smallAll),
        labelStyle: GoogleFonts.poppins(fontSize: 13),
      ),

      // Text theme
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ══════════════════════════════
  //  DARK THEME
  // ══════════════════════════════
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        error: AppColors.darkError,
        surface: AppColors.darkSurface,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeAll,
          side: BorderSide(color: AppColors.darkSurfaceVariant),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: AppColors.darkSurfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: AppColors.darkSurfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.darkTextSecondary,
        ),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
        backgroundColor: AppColors.darkSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Text
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.darkTextPrimary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}

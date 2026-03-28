import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF0061A8); // Matched from Figma
  static const Color secondary = Color(0xFFFF5A5F);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color border = Color(0xFFE9ECEF);
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displaySmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

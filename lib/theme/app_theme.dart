import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static bool isLightMode = false;

  // Backgrounds
  static Color get background => isLightMode ? const Color(0xFFF5F7FA) : const Color(0xFF0B1020);
  static Color get cardColor => isLightMode ? const Color(0xFFFFFFFF) : const Color(0xFF141A2E);
  static Color get surfaceColor => isLightMode ? const Color(0xFFE4E7EB) : const Color(0xFF1C2340);
  static Color get inputColor => isLightMode ? const Color(0xFFF0F2F5) : const Color(0xFF1A1F35);

  // Accent
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF8B83FF);
  static const Color accentDark = Color(0xFF4A43C4);

  // Text
  static Color get textPrimary => isLightMode ? const Color(0xFF1A1F35) : const Color(0xFFFFFFFF);
  static Color get textSecondary => isLightMode ? const Color(0xFF5A6380) : const Color(0xFF9BA3C7);
  static Color get textHint => isLightMode ? const Color(0xFF9BA3C7) : const Color(0xFF5A6380);

  // Status
  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF4C6A);
  static const Color info = Color(0xFF4B9EFF);

  // Note icon colors
  static const Color noteBlue = Color(0xFF3B5BDB);
  static const Color noteGreen = Color(0xFF2E7D32);
  static const Color noteOrange = Color(0xFFE65100);
  static const Color notePurple = Color(0xFF6A1B9A);
  static const Color noteTeal = Color(0xFF00695C);

  // Border / Divider
  static Color get border => isLightMode ? const Color(0xFFDCDFE5) : const Color(0xFF252D4A);
  static Color get divider => isLightMode ? const Color(0xFFE4E7EB) : const Color(0xFF1E2540);

  // Glow
  static Color get accentGlow => accent.withValues(alpha: 0.25);
  static Color get accentGlowDeep => accent.withValues(alpha: 0.15);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: AppColors.isLightMode ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme(
          brightness: AppColors.isLightMode ? Brightness.light : Brightness.dark,
          primary: AppColors.accent,
          onPrimary: Colors.white,
          secondary: AppColors.accentLight,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.cardColor,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(AppColors.isLightMode ? ThemeData.light().textTheme : ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
          labelStyle: GoogleFonts.poppins(color: AppColors.accent, fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            elevation: 0,
          ),
        ),
        dividerTheme: DividerThemeData(color: AppColors.divider, thickness: 1),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      );
}

// Reusable text styles
class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle get bodyWhite => GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textHint);

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle get accent => GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent);

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
}

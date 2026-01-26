import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color darkGreen = Color(0xFF1D503A);
  static const Color deepGreen = Color(0xFF0A2316);
  static const Color offWhite = Color(0xFFFAF5EE);
  static const Color emergr = Color(0xFF2D6A4F);

  // Lexend for Titles/Headings
  static TextStyle get titleStyle => GoogleFonts.lexend();

  // Playfair Display for Body/Verses
  static TextStyle get bodyStyle => GoogleFonts.playfair();

  static ThemeData getLightTheme() {
    return _buildTheme(
      brightness: Brightness.light,
      background: offWhite,
      foreground: darkGreen,
      accent: darkGreen,
    );
  }

  static ThemeData getDarkTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      background: deepGreen,
      foreground: offWhite,
      accent: emergr,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color foreground,
    required Color accent,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        onPrimary: offWhite,
        surface: background,
        onSurface: foreground,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          statusBarBrightness: brightness,
        ),
        titleTextStyle: GoogleFonts.lexend(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      iconTheme: IconThemeData(color: foreground),
      textTheme: TextTheme(
        bodyMedium: bodyStyle.copyWith(color: foreground, fontSize: 16),
        bodyLarge: bodyStyle.copyWith(color: foreground, fontSize: 18),
        bodySmall: bodyStyle.copyWith(color: foreground, fontSize: 14),
        titleLarge: titleStyle.copyWith(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: titleStyle.copyWith(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: titleStyle.copyWith(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        headlineSmall: titleStyle.copyWith(
          color: foreground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: titleStyle.copyWith(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: titleStyle.copyWith(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: titleStyle.copyWith(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: titleStyle.copyWith(
          color: foreground.withValues(alpha: 0.6),
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        prefixIconColor: foreground,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: accent,
        contentTextStyle: GoogleFonts.lexend(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
    );
  }
}

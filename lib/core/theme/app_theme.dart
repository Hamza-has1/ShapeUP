import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand color
  static const Color primaryPurple = Color(0xff6c3baa); // #6C3BAA
  static const Color accentPurple = Color(0xff6c3baa);
  static const Color electricPurple = Color(0xff6c3baa);
  
  // Light Mode Colors
  static const Color lightBg = Color(0xffffffff);
  static const Color lightCardBg = Color(0xffffffff);
  static const Color lightText = Color(0xff6c3baa);
  static const Color lightTextSecondary = Color(0xff6c3baa);
  
  // Dark Mode Colors
  static const Color darkBg = Color(0xff000000);
  static const Color darkCardBg = Color(0xff000000);
  static const Color darkText = Color(0xffffffff);
  static const Color darkTextSecondary = Color(0xff6c3baa);

  // Status & UI colors (aligned to fit the constraints)
  static const Color success = Color(0xff6c3baa);
  static const Color warning = Color(0xff6c3baa);
  static const Color error = Color(0xff6c3baa);
  static const Color info = Color(0xff6c3baa);

  // Luxury Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primaryPurple, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryDarkGradient = LinearGradient(
    colors: [Color(0xff000000), Color(0xff000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient luxuryLightGradient = LinearGradient(
    colors: [Color(0xffffffff), Color(0xffffffff)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient neonPurpleGradient = LinearGradient(
    colors: [primaryPurple, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryPurple,
      scaffoldBackgroundColor: AppColors.lightBg,
      cardColor: AppColors.lightCardBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPurple,
        secondary: AppColors.accentPurple,
        surface: AppColors.lightCardBg,
        error: AppColors.error,
      ),
      textTheme: _getTextTheme(AppColors.lightText, AppColors.lightTextSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightText),
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryPurple,
      scaffoldBackgroundColor: AppColors.darkBg,
      cardColor: AppColors.darkCardBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        secondary: AppColors.accentPurple,
        surface: AppColors.darkCardBg,
        error: AppColors.error,
      ),
      textTheme: _getTextTheme(AppColors.darkText, AppColors.darkTextSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkText),
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  static TextTheme _getTextTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: primaryText,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: secondaryText,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: secondaryText,
      ),
    );
  }
}

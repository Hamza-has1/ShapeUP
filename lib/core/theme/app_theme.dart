import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand color
  static const Color primaryPurple = Color(0xff40046b); // #40046B
  static const Color accentPurple = Color(0xff6e10b1);
  static const Color electricPurple = Color(0xffa133f6);
  
  // Light Mode Colors
  static const Color lightBg = Colors.white;
  static const Color lightCardBg = Color(0xfff7f3fb);
  static const Color lightText = Color(0xff120120);
  static const Color lightTextSecondary = Color(0xff605070);
  
  // Dark Mode Colors
  static const Color darkBg = Color(0xff090010); // True dark luxury purple-black
  static const Color darkCardBg = Color(0xff180525); // Subtle dark purple card
  static const Color darkText = Color(0xfff2e6ff);
  static const Color darkTextSecondary = Color(0xffb29ecc);

  // Status & UI colors
  static const Color success = Color(0xff00d084);
  static const Color warning = Color(0xffffab00);
  static const Color error = Color(0xffff3b30);
  static const Color info = Color(0xff007aff);

  // Luxury Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primaryPurple, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryDarkGradient = LinearGradient(
    colors: [Color(0xff140121), Color(0xff090010)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient luxuryLightGradient = LinearGradient(
    colors: [Color(0xffffffff), Color(0xfff7f3fb)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient neonPurpleGradient = LinearGradient(
    colors: [Color(0xff9d4edd), Color(0xffe0aaff)],
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

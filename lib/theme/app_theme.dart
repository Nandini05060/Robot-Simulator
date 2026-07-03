import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Blucursor Brand Colors (Dark Futuristic Palette)
  static const Color primaryColor = Color(0xff55E8FF);   // Electric Blue
  static const Color accentColor = Color(0xff00D2FF);    // Neon Blue Accent
  static const Color highlightColor = Color(0xff8A8D99); // Secondary Gray
  
  // Custom Status Colors
  static const Color successColor = Color(0xff00D2FF);   // Neon Blue Accent
  static const Color warningColor = Color(0xffFFB800);   // Cyber Orange
  static const Color dangerColor = Color(0xffFF4B5C);    // Neon Red
  
  // Shared Dark Space Themes (Unified UI experience)
  static const Color darkBg = Color(0xff090A0F);         // Dark Space Background
  static const Color darkSurface = Color(0xff141822);    // Obsidian Card Background
  static const Color darkTextPrimary = Color(0xffF5F5F5);  // Soft White
  static const Color darkTextSecondary = Color(0xff8A8D99); // Secondary Gray
  static const Color darkBorder = Color(0x2655e8ff);     // Glowing Electric Border (15% opacity)

  static ThemeData get lightTheme {
    // Return a dark command center theme even for light settings to preserve sci-fi aesthetic
    return darkTheme;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: highlightColor,
        surface: darkSurface,
        background: darkBg,
        onPrimary: darkBg,
        onSecondary: darkBg,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBg,
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
          titleLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
          titleMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge: const TextStyle(color: darkTextPrimary, fontSize: 16),
          bodyMedium: const TextStyle(color: darkTextSecondary, fontSize: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: darkBg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.8),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
      ),
    );
  }
}

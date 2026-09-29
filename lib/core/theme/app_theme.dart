import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.cream,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.burgundy,
      primary: AppColors.burgundy,
      secondary: AppColors.brown,
      surface: AppColors.white,
      brightness: Brightness.light,
    ),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        color: AppColors.dark,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        color: AppColors.dark,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        color: AppColors.dark,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: AppColors.dark,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: AppColors.dark,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.inter(
        color: AppColors.dark,
      ),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.dark,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.dark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: AppColors.dark,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.burgundy,
          width: 2,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.burgundy,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF151211),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.burgundy,
      brightness: Brightness.dark,
      primary: const Color(0xFFE8A29B),
      secondary: const Color(0xFFD7A56D),
      surface: const Color(0xFF241F1D),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        color: const Color(0xFFF5EFEC),
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        color: const Color(0xFFF5EFEC),
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        color: const Color(0xFFF5EFEC),
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: const Color(0xFFF5EFEC),
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: const Color(0xFFF5EFEC),
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.inter(color: const Color(0xFFF5EFEC)),
      bodyMedium: GoogleFonts.inter(color: const Color(0xFFF5EFEC)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF151211),
      foregroundColor: const Color(0xFFF5EFEC),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: const Color(0xFFF5EFEC),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF302927),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF514744)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF514744)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8A29B), width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFFB7AAA5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9F3C37),
        foregroundColor: const Color(0xFFFFFFFF),
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF241F1D),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

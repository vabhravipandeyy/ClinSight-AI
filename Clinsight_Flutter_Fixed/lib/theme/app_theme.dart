import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color navyBg = Color(0xFFF8FAFC);
  static const Color navyCard = Color(0xFFFFFFFF);
  static const Color navyLight = Color(0xFFF1F5F9);
  static const Color cyan = Color(0xFF0F172A);
  static const Color cyanDark = Color(0xFF1E293B);
  static const Color brandCyan = Color(0xFF0E7490);
  static const Color white = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSecondary = Color(0xFF334155);
  static const Color success = Color(0xFF10B981);
  static const Color successText = Color(0xFF15803D);
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningText = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerText = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color borderColor = Color(0xFFE2E8F0);

  static ThemeData get darkTheme {
    final base = GoogleFonts.ibmPlexSansTextTheme();
    final heading = GoogleFonts.ibmPlexSerifTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: navyBg,
      colorScheme: const ColorScheme.light(
        primary: cyan,
        secondary: cyanDark,
        surface: navyCard,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: white,
      ),
      textTheme: base.copyWith(
        displayLarge: heading.displayLarge
            ?.copyWith(color: white, fontWeight: FontWeight.w700),
        displayMedium: heading.displayMedium
            ?.copyWith(color: white, fontWeight: FontWeight.w700),
        headlineLarge: heading.headlineLarge
            ?.copyWith(color: white, fontWeight: FontWeight.w700),
        headlineMedium: heading.headlineMedium
            ?.copyWith(color: white, fontWeight: FontWeight.w700),
        headlineSmall: heading.headlineSmall
            ?.copyWith(color: white, fontWeight: FontWeight.w700),
        titleLarge: heading.titleLarge
            ?.copyWith(color: white, fontWeight: FontWeight.w700),
        titleMedium: base.titleMedium
            ?.copyWith(color: white, fontWeight: FontWeight.w600),
        titleSmall: base.titleSmall
            ?.copyWith(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: base.bodyLarge?.copyWith(color: textSecondary),
        bodyMedium: base.bodyMedium?.copyWith(color: textMuted),
        bodySmall: base.bodySmall?.copyWith(color: textMuted),
        labelLarge: base.labelLarge
            ?.copyWith(color: white, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navyBg,
        elevation: 0,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: navyCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navyCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cyan, width: 1.2),
        ),
      ),
      dividerColor: borderColor,
    );
  }
}

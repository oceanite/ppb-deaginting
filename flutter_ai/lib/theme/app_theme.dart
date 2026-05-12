import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color backgroundLight = Color(0xFFF5F2EE);
  static const Color surfaceLight = Color(0xFFECE8E1);
  static const Color primaryTeal = Color(0xFF3D7A8A);
  static const Color accentSand = Color(0xFFB8935A);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Empathy Map Card Colors
  static const Color feelingsColor = Color(0xFFE8D5C4);
  static const Color thoughtsColor = Color(0xFFD4E8D5);
  static const Color painColor = Color(0xFFE8D4D4);
  static const Color actionsColor = Color(0xFFD4D8E8);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: primaryTeal,
          secondary: accentSand,
          surface: surfaceLight,
        ),
        fontFamily: 'Georgia', // Elegant serif
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.5,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: textSecondary,
          ),
        ),
      );
}
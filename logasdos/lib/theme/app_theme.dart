import 'package:flutter/material.dart';

class AppColors {
  // Primary - Purple
  static const primary = Color(0xFF3C3489);
  static const primaryLight = Color(0xFFEEEDFE);
  static const primaryMid = Color(0xFF534AB7);
  static const primaryBorder = Color(0xFFAFA9EC);

  // Status
  static const approved = Color(0xFF3B6D11);
  static const approvedBg = Color(0xFFEAF3DE);
  static const pending = Color(0xFF854F0B);
  static const pendingBg = Color(0xFFFAEEDA);
  static const pendingColor = Color.fromARGB(255, 235, 214, 53);
  static const pendingIcon = Color(0xFFEF9F27);
  static const rejected = Color(0xFFA32D2D);
  static const rejectedBg = Color(0xFFFCEBEB);

  // Info / Blue
  static const info = Color(0xFF185FA5);
  static const infoBg = Color(0xFFE6F1FB);

  // Teal
  static const teal = Color(0xFF0F6E56);
  static const tealBg = Color(0xFFE1F5EE);

  // Coral
  static const coral = Color(0xFF993C1D);
  static const coralBg = Color(0xFFFAECE7);

  // Neutral
  static const surface = Color(0xFFF8F8F8);
  static const border = Color(0xFFE0E0E0);
  static const textSecondary = Color(0xFF888780);
  static const textTertiary = Color(0xFFB4B2A9);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        color: Colors.white,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 0.5),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
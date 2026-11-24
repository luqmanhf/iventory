import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Base (matching imageplan)
  static const Color background = Color(0xFF111315);
  static const Color surface = Color(0xFF191B1F);
  static const Color surfaceCard = Color(0xFF1C1E23);
  static const Color surfaceLight = Color(0xFF262932);
  static const Color border = Color(0xFF2A2D35);
  static const Color borderSubtle = Color(0xFF22242B);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E929D);
  static const Color textMuted = Color(0xFF5A5E6B);

  // Accent & Action Colors (matching image copy.png)
  static const Color buttonFoto = Color(0xFF707BFB);
  static const Color buttonLokasi = Color(0xFF9AA5FF);
  static const Color buttonLokasiBg = Color(0xFF8D99EE);
  static const Color primaryBlue = Color(0xFF4C6FFF);

  // Metric & Status Colors
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFE8FDF4);
  static const Color red = Color(0xFFEF4444);
  static const Color orangeWarning = Color(0xFFF59E0B);
  static const Color orangeWarningLight = Color(0xFFFEF3C7);
  static const Color peachLowStock = Color(0xFFFFECE5);
  static const Color peachText = Color(0xFFE05638);
  static const Color cyan = Color(0xFF00C2FF);

  // Legacy mappings for backwards compatibility
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color surfaceMuted = Color(0xFF262932);
  static const Color shadow = Color(0x33000000);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.buttonFoto,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Keep lightTheme as getter pointing to darkTheme to enforce unified dark aesthetic
  static ThemeData get lightTheme => darkTheme;
}

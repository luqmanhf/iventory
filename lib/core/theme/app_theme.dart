import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();
  ThemeController._internal();

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}

class AppColors {
  
  static const Color background = Color(0xFF111315);
  static const Color surface = Color(0xFF191B1F);
  static const Color surfaceCard = Color(0xFF1C1E23);
  static const Color surfaceLight = Color(0xFF262932);
  static const Color border = Color(0xFF2A2D35);
  static const Color borderSubtle = Color(0xFF22242B);

  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E929D);
  static const Color textMuted = Color(0xFF5A5E6B);

  
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceCard = Color(0xFFF3F4F6);
  static const Color lightSurfaceLight = Color(0xFFE5E7EB);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFE5E7EB);

  
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  static Color getBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? background : lightBackground;

  static Color getSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surface : lightSurface;

  static Color getSurfaceCard(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceCard : lightSurfaceCard;

  static Color getSurfaceLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceLight : lightSurfaceLight;

  static Color getBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? border : lightBorder;

  static Color getTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimary : lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondary : lightTextSecondary;

  static Color getTextMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textMuted : lightTextMuted;

  static Color getThumbnailBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF242730) : const Color(0xFFE5E7EB);

  static Color getThumbnailIcon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A5E6B) : const Color(0xFF9CA3AF);

  static Color getBottomNavBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? background : lightSurface;

  static Color getNavPillBg(BuildContext context, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isSelected) return Colors.transparent;
    return isDark ? const Color(0xFF232C4B) : const Color(0xFFEEF2FF);
  }

  static const Color buttonFoto = Color(0xFF707BFB);
  static const Color buttonLokasi = Color(0xFF9AA5FF);
  static const Color green = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);
}

class AppTheme {
  static const String fontFamily = 'Geist';

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontFamily,
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
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.buttonFoto,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

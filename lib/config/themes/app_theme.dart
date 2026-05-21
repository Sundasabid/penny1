import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.neon,
      secondary: AppColors.neonSoft,
      surface: AppColors.lightSurface,
      error: AppColors.danger,
    ),
    dividerColor: AppColors.lightBorder,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textOnLight,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.textOnLight,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.textOnLight,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textOnLight,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.textOnLight,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.textOnLight),
      bodyMedium: TextStyle(color: AppColors.textOnLight),
      bodySmall: TextStyle(color: AppColors.textOnLightMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textOnLight),
      titleTextStyle: TextStyle(
        color: AppColors.textOnLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neon,
      secondary: AppColors.neonSoft,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textOnDark,
      error: AppColors.danger,
      outline: AppColors.darkBorder,
    ),
    dividerColor: AppColors.darkBorder,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textOnDark,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.textOnDark,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.textOnDark,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textOnDark,
        fontWeight: FontWeight.w900,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textOnDark,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.textOnDark,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.textOnDark),
      bodyMedium: TextStyle(color: AppColors.textOnDark),
      bodySmall: TextStyle(color: AppColors.textOnDarkMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textOnDark),
      titleTextStyle: TextStyle(
        color: AppColors.textOnDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: AppColors.neon.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      hintStyle: const TextStyle(color: AppColors.textOnDarkMuted),
      prefixIconColor: AppColors.textOnDarkMuted,
      suffixIconColor: AppColors.textOnDarkMuted,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.neon, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
  );
}

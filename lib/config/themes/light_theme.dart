// lib/src/app/theme/light_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildLightTheme() {
  final colorScheme = const ColorScheme.light(
    primary: AppColors.neon,
    secondary: AppColors.neonSoft,
    tertiary: AppColors.neonDark,
    surface: AppColors.lightSurface,
    surfaceContainerHighest: AppColors.lightSurface2,
    error: AppColors.danger,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: AppColors.textOnLight,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.lightBg,
    canvasColor: AppColors.lightBg,
    fontFamily: AppTextStyles.fontFamily,
    textTheme: AppTextStyles.textTheme(isDark: false),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textOnLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),


    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface2,
      hintStyle: const TextStyle(color: AppColors.textOnLightMuted),
      labelStyle: const TextStyle(color: AppColors.textOnLightMuted),
      prefixIconColor: AppColors.textOnLightMuted,
      suffixIconColor: AppColors.textOnLightMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.neon, width: 1.2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.black,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textOnLight,
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.neonDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.neonDark,
      unselectedItemColor: AppColors.textOnLightMuted,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.neon,
      foregroundColor: Colors.black,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
  );
}

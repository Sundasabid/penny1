// lib/src/app/theme/dark_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildDarkTheme() {
  final colorScheme = const ColorScheme.dark(
    primary: AppColors.neon,
    secondary: AppColors.neonSoft,
    tertiary: AppColors.neonDark,
    surface: AppColors.darkSurface,
    surfaceContainerHighest: AppColors.darkSurface2,
    error: AppColors.danger,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: AppColors.textOnDark,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.darkBg,
    canvasColor: AppColors.darkBg,
    fontFamily: AppTextStyles.fontFamily,
    textTheme: AppTextStyles.textTheme(isDark: true),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface2,
      hintStyle: const TextStyle(color: AppColors.textOnDarkMuted),
      labelStyle: const TextStyle(color: AppColors.textOnDarkMuted),
      prefixIconColor: AppColors.textOnDarkMuted,
      suffixIconColor: AppColors.textOnDarkMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.neon, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
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
        foregroundColor: AppColors.textOnDark,
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.neon,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.neon,
      unselectedItemColor: AppColors.textOnDarkMuted,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.neon,
      foregroundColor: Colors.black,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
  );
}

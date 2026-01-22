// lib/src/app/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// PENNY typography system.
/// Matches the fintech look from your screenshots:
/// - Bold headings
/// - Clean readable body
///
/// If you want pixel-perfect typography, add a font (e.g. Inter/Sora/PlusJakartaSans)
/// in pubspec.yaml and keep the same `fontFamily` name here.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static TextTheme textTheme({required bool isDark}) {
    final onBg = isDark ? AppColors.textOnDark : AppColors.textOnLight;
    final muted = isDark ? AppColors.textOnDarkMuted : AppColors.textOnLightMuted;

    return TextTheme(
      // Headlines
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: onBg,
        letterSpacing: -0.6,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        height: 1.18,
        fontWeight: FontWeight.w800,
        color: onBg,
        letterSpacing: -0.4,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: onBg,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        height: 1.22,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),

      // Titles
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: muted,
      ),

      // Body
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: onBg,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: onBg,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: muted,
      ),

      // Labels
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: muted,
      ),
    );
  }

  /// Accent style used for brand headings (“PENNY”).
  static TextStyle brand({
    required bool isDark,
    double size = 26,
    FontWeight weight = FontWeight.w800,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: 1.05,
      fontWeight: weight,
      color: AppColors.neon,
      letterSpacing: 1.0,
    );
  }

  /// Link style (e.g., “Forgot password?”).
  static TextStyle link({required bool isDark}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      height: 1.1,
      fontWeight: FontWeight.w700,
      color: AppColors.neon,
    );
  }
}

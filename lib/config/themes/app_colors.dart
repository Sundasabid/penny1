// lib/src/app/theme/app_colors.dart
import 'package:flutter/material.dart';

/// PENNY color system.
/// - Neon green accent remains consistent across light/dark.
/// - Dark uses deep charcoal with subtle teal tint.
/// - Light uses clean off-white surfaces with the same neon accent.
class AppColors {
  AppColors._();

  // Brand / Accent
  static const Color neon = Color(0xFF18B27A); // Premium neon green
  static const Color neonSoft = Color(0xFF2ECC71);
  static const Color neonDark = Color(0xFF0D9E6D);

  // Dark theme base
  static const Color darkBg = Color(0xFF0B0E11); // Deep charcoal black
  static const Color darkSurface = Color(0xFF171C22);
  static const Color darkSurface2 = Color(0xFF232B35);
  static const Color darkCard = Color(0xFF1C252E);
  static const Color darkBorder = Color(0xFF2E3A47);

  // Light theme base
  static const Color lightBg = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFF98A2B3);
  static const Color textOnLight = Color(0xFF101828);
  static const Color textOnLightMuted = Color(0xFF667085);

  // Status
  static const Color danger = Color(0xFFF04438);
  static const Color warning = Color(0xFFFDB022);
  static const Color info = Color(0xFF2E90FA);

  // Specific heatmap colors from image
  static const Color heatmapNone = Color(0xFF2E3539);
  static const Color heatmapLow = Color(0xFF18B27A);
  static const Color heatmapHigh = Color(0xFFF04438);

  static List<BoxShadow> neonGlow({
    double blur = 20,
    double spread = 1,
    double opacity = 0.25,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: neon.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: spread,
        offset: offset,
      ),
    ];
  }
}

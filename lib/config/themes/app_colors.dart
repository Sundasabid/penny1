// lib/src/app/theme/app_colors.dart
import 'package:flutter/material.dart';

/// PENNY color system.
/// - Neon green accent remains consistent across light/dark.
/// - Dark uses deep charcoal with subtle teal tint.
/// - Light uses clean off-white surfaces with the same neon accent.
class AppColors {
  AppColors._();

  // Brand / Accent (constant across themes)
  static const Color neon = Color(0xFF00E676); // neon green
  static const Color neonSoft = Color(0xFF4DFF9A); // softer neon highlight
  static const Color neonDark = Color(0xFF00C853); // pressed/active

  // Dark theme base
  static const Color darkBg = Color(0xFF050B10);
  static const Color darkBg2 = Color(0xFF07131A); // subtle blue/teal tint
  static const Color darkSurface = Color(0xFF0B161F);
  static const Color darkSurface2 = Color(0xFF0E1D27);
  static const Color darkCard = Color(0xFF0D1821);

  // Light theme base
  static const Color lightBg = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Text
  static const Color textOnDark = Color(0xFFEAF2F7);
  static const Color textOnDarkMuted = Color(0xFFA9BAC7);
  static const Color textOnLight = Color(0xFF0B1220);
  static const Color textOnLightMuted = Color(0xFF5B6B78);

  // Lines / borders
  static const Color darkBorder = Color(0xFF1D2A35);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Status
  static const Color danger = Color(0xFFFF4D4D);
  static const Color warning = Color(0xFFFFB020);
  static const Color info = Color(0xFF2EA8FF);

  // Shadows
  static const Color shadowDark = Color(0x66000000);
  static const Color shadowLight = Color(0x22000000);

  /// Neon glow used for accent components (especially in dark theme).
  /// Use in custom widgets (e.g., PennyCard/PennyButton) via BoxDecoration.
  static List<BoxShadow> neonGlow({
    double blur = 22,
    double spread = 0.5,
    double opacity = 0.35,
    Offset offset = const Offset(0, 8),
  }) {
    return [
      BoxShadow(
        color: neon.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: spread,
        offset: offset,
      ),
      BoxShadow(
        color: neonSoft.withValues(alpha: opacity * 0.55),
        blurRadius: blur * 1.3,
        spreadRadius: spread * 0.3,
        offset: offset,
      ),
    ];
  }
}

// lib/src/app/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Main theme entry point for PENNY.
///
/// Usage:
/// MaterialApp(
///   title: 'PENNY',
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system, // or from settings
/// )
class AppTheme {
  AppTheme._();

  static ThemeData get light => buildLightTheme();
  static ThemeData get dark => buildDarkTheme();
}

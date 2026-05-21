import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _settingsBoxName = 'settings';
  static const String _themeModeKey = 'theme_mode';
  static const String _lastEmailKey = 'last_email';
  static const String _currencyKey = 'currency';
  static const String _smsSyncEnabledKey = 'sms_sync_enabled';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_settingsBoxName);
  }

  // Theme Mode
  ThemeMode getThemeMode() {
    final index = _box.get(_themeModeKey, defaultValue: ThemeMode.system.index);
    return ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_themeModeKey, mode.index);
  }

  // Last Login Email
  String? getLastEmail() {
    return _box.get(_lastEmailKey);
  }

  Future<void> setLastEmail(String email) async {
    await _box.put(_lastEmailKey, email);
  }

  // Currency
  String? getCurrency() {
    return _box.get(_currencyKey);
  }

  Future<void> setCurrency(String currency) async {
    await _box.put(_currencyKey, currency);
  }

  // SMS Sync
  bool isSmsSyncEnabled() {
    return _box.get(_smsSyncEnabledKey, defaultValue: false);
  }

  Future<void> setSmsSyncEnabled(bool enabled) async {
    await _box.put(_smsSyncEnabledKey, enabled);
  }

  // Onboarding
  bool hasSeenOnboarding() {
    return _box.get(_hasSeenOnboardingKey, defaultValue: false);
  }

  Future<void> setHasSeenOnboarding(bool seen) async {
    await _box.put(_hasSeenOnboardingKey, seen);
  }
}

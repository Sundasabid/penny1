import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../../../core/services/settings_service.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SettingsService _settingsService;

  ThemeBloc({required SettingsService settingsService}) 
    : _settingsService = settingsService,
      super(const ThemeState(ThemeMode.light)) {
    
    on<ToggleThemeRequested>((event, emit) async {
      final newMode = state.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      
      await _settingsService.setThemeMode(newMode);
      emit(ThemeState(newMode));
    });

    on<LoadThemeRequested>((event, emit) {
      final savedMode = _settingsService.getThemeMode();
      emit(ThemeState(savedMode));
    });
  }
}

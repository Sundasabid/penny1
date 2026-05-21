import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ToggleThemeRequested extends ThemeEvent {}

class LoadThemeRequested extends ThemeEvent {}

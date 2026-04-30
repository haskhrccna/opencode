import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Theme state that can be persisted
class ThemeState {
  const ThemeState({this.themeMode = ThemeMode.light});

  factory ThemeState.light() => const ThemeState();
  factory ThemeState.dark() => const ThemeState(themeMode: ThemeMode.dark);
  factory ThemeState.system() => const ThemeState(themeMode: ThemeMode.system);

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    final themeModeName = json['themeMode'] as String?;
    var mode = ThemeMode.light;

    if (themeModeName != null) {
      try {
        mode = ThemeMode.values.byName(themeModeName);
      } catch (_) {
        mode = ThemeMode.light;
      }
    }

    return ThemeState(themeMode: mode);
  }
  final ThemeMode themeMode;

  bool get isLight => themeMode == ThemeMode.light;
  bool get isDark => themeMode == ThemeMode.dark;
  bool get isSystem => themeMode == ThemeMode.system;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.name};
  }

  @override
  String toString() => 'ThemeState(themeMode: $themeMode)';
}

/// Cubit for managing app theme with persistence
class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  /// Set theme to light mode
  void setLight() => emit(const ThemeState());

  /// Set theme to dark mode
  void setDark() => emit(const ThemeState(themeMode: ThemeMode.dark));

  /// Set theme to system mode
  void setSystem() => emit(const ThemeState(themeMode: ThemeMode.system));

  /// Toggle between light and dark mode
  void toggle() {
    if (state.isDark || (state.isSystem && _isSystemDark)) {
      setLight();
    } else {
      setDark();
    }
  }

  /// Check if system is in dark mode
  bool get _isSystemDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  ThemeState? fromJson(Map<String, dynamic> json) => ThemeState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ThemeState state) => state.toJson();
}

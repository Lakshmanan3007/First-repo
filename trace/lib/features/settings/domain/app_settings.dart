import 'package:flutter/material.dart';

/// Persistent application settings used across TRACE.
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.use24Hour,
  });

  final AppThemeMode themeMode;
  final bool use24Hour;

  static const defaults = AppSettings(
    themeMode: AppThemeMode.system,
    use24Hour: true,
  );

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? use24Hour,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      use24Hour: use24Hour ?? this.use24Hour,
    );
  }

  ThemeMode get materialThemeMode {
    return switch (themeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}

enum AppThemeMode {
  system,
  light,
  dark,
}

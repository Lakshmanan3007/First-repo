import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._prefs);

  static const _themeKey = 'trace_app_theme_mode';
  static const _use24HourKey = 'trace_app_use_24_hour';

  final SharedPreferences _prefs;

  static Future<AppSettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsRepository(prefs);
  }

  AppSettings load() {
    final themeMode = _themeFromString(_prefs.getString(_themeKey));
    final use24Hour = _prefs.getBool(_use24HourKey) ?? AppSettings.defaults.use24Hour;
    return AppSettings(themeMode: themeMode, use24Hour: use24Hour);
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_themeKey, _themeToString(settings.themeMode));
    await _prefs.setBool(_use24HourKey, settings.use24Hour);
  }

  Future<void> reset() async {
    await _prefs.remove(_themeKey);
    await _prefs.remove(_use24HourKey);
  }

  AppThemeMode _themeFromString(String? value) {
    return switch (value) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      'system' => AppThemeMode.system,
      _ => AppSettings.defaults.themeMode,
    };
  }

  String _themeToString(AppThemeMode themeMode) {
    return switch (themeMode) {
      AppThemeMode.light => 'light',
      AppThemeMode.dark => 'dark',
      AppThemeMode.system => 'system',
    };
  }
}

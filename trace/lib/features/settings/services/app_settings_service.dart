import 'package:flutter/foundation.dart';

import '../data/app_settings_repository.dart';
import '../domain/app_settings.dart';

class AppSettingsService extends ValueNotifier<AppSettings> {
  AppSettingsService._(AppSettings value, this._repository) : super(value);

  final AppSettingsRepository _repository;

  static Future<AppSettingsService> create() async {
    final repository = await AppSettingsRepository.create();
    final settings = repository.load();
    return AppSettingsService._(settings, repository);
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    value = value.copyWith(themeMode: themeMode);
    await _repository.save(value);
    notifyListeners();
  }

  Future<void> updateUse24Hour(bool use24Hour) async {
    value = value.copyWith(use24Hour: use24Hour);
    await _repository.save(value);
    notifyListeners();
  }

  Future<void> reset() async {
    await _repository.reset();
    value = AppSettings.defaults;
    notifyListeners();
  }
}

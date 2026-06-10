import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_preferences.dart';

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._prefs);

  static const _pushKey = 'notifications_push_enabled';
  static const _taskActivatedSilentKey = 'notifications_task_activated_silent';
  static const _oneHourRemainingKey = 'notifications_one_hour_remaining_minutes';
  static const _tenMinutesRemainingKey = 'notifications_ten_minutes_remaining_minutes';

  final SharedPreferences _prefs;

  static Future<NotificationPreferencesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferencesRepository(prefs);
  }

  NotificationPreferences load() {
    return NotificationPreferences(
      pushEnabled: _prefs.getBool(_pushKey) ??
          NotificationPreferences.defaults.pushEnabled,
      taskActivatedSilent: _prefs.getBool(_taskActivatedSilentKey) ??
          NotificationPreferences.defaults.taskActivatedSilent,
      oneHourRemainingMinutes: _prefs.getInt(_oneHourRemainingKey) ??
          NotificationPreferences.defaults.oneHourRemainingMinutes,
      tenMinutesRemainingMinutes: _prefs.getInt(_tenMinutesRemainingKey) ??
          NotificationPreferences.defaults.tenMinutesRemainingMinutes,
    );
  }

  Future<void> save(NotificationPreferences preferences) async {
    await _prefs.setBool(_pushKey, preferences.pushEnabled);
    await _prefs.setBool(_taskActivatedSilentKey, preferences.taskActivatedSilent);
    await _prefs.setInt(
      _oneHourRemainingKey,
      preferences.oneHourRemainingMinutes,
    );
    await _prefs.setInt(
      _tenMinutesRemainingKey,
      preferences.tenMinutesRemainingMinutes,
    );
  }
}

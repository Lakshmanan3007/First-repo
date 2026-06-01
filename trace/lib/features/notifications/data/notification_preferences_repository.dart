import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_preferences.dart';

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._prefs);

  static const _pushKey = 'notifications_push_enabled';
  static const _emailKey = 'notifications_email_digests';
  static const _warningMinutesKey = 'notifications_deadline_warning_minutes';
  static const _criticalMinutesKey = 'notifications_deadline_critical_minutes';

  final SharedPreferences _prefs;

  static Future<NotificationPreferencesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferencesRepository(prefs);
  }

  NotificationPreferences load() {
    return NotificationPreferences(
      pushEnabled: _prefs.getBool(_pushKey) ??
          NotificationPreferences.defaults.pushEnabled,
      emailDigests: _prefs.getBool(_emailKey) ??
          NotificationPreferences.defaults.emailDigests,
      deadlineWarningMinutes: _prefs.getInt(_warningMinutesKey) ??
          NotificationPreferences.defaults.deadlineWarningMinutes,
      deadlineCriticalMinutes: _prefs.getInt(_criticalMinutesKey) ??
          NotificationPreferences.defaults.deadlineCriticalMinutes,
    );
  }

  Future<void> save(NotificationPreferences preferences) async {
    await _prefs.setBool(_pushKey, preferences.pushEnabled);
    await _prefs.setBool(_emailKey, preferences.emailDigests);
    await _prefs.setInt(
      _warningMinutesKey,
      preferences.deadlineWarningMinutes,
    );
    await _prefs.setInt(
      _criticalMinutesKey,
      preferences.deadlineCriticalMinutes,
    );
  }
}

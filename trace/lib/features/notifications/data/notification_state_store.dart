import 'package:shared_preferences/shared_preferences.dart';

import '../../tasks/domain/task_status.dart';

/// Tracks lifecycle snapshots and dismissed in-app alerts.
class NotificationStateStore {
  NotificationStateStore(this._prefs);

  static const _statusPrefix = 'notification_last_status_';
  static const _dismissedKey = 'notification_dismissed_ids';

  final SharedPreferences _prefs;

  static Future<NotificationStateStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationStateStore(prefs);
  }

  TaskStatus? lastStatusFor(String taskId) {
    final raw = _prefs.getString('$_statusPrefix$taskId');
    if (raw == null) return null;
    return TaskStatus.values.asNameMap()[raw];
  }

  Future<void> setLastStatus(String taskId, TaskStatus status) async {
    await _prefs.setString('$_statusPrefix$taskId', status.name);
  }

  Set<String> dismissedIds() {
    final raw = _prefs.getStringList(_dismissedKey);
    return raw?.toSet() ?? {};
  }

  Future<void> dismiss(String notificationId) async {
    final current = dismissedIds()..add(notificationId);
    await _prefs.setStringList(_dismissedKey, current.toList());
  }

  Future<void> clearDismissed() async {
    await _prefs.remove(_dismissedKey);
  }

  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where(
      (key) =>
          key.startsWith(_statusPrefix) || key == _dismissedKey,
    );
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

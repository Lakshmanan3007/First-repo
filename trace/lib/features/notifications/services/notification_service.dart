import '../../tasks/domain/task.dart';
import '../data/notification_preferences_repository.dart';
import '../data/notification_state_store.dart';
import '../domain/notification_preferences.dart';
import '../domain/trace_notification.dart';
import 'notification_coordinator.dart';

class NotificationService {
  NotificationService({
    required NotificationPreferencesRepository preferences,
    required NotificationStateStore state,
    required NotificationCoordinator coordinator,
  })  : _preferences = preferences,
        _coordinator = coordinator,
        _state = state;

  final NotificationPreferencesRepository _preferences;
  final NotificationCoordinator _coordinator;
  final NotificationStateStore _state;

  NotificationPreferences get preferences => _preferences.load();

  Future<void> savePreferences(
    NotificationPreferences preferences,
  ) async {
    await _preferences.save(preferences);
  }

  Future<List<TraceNotification>> evaluateTasks(List<Task> tasks) {
    return _coordinator.evaluate(
      tasks: tasks,
      preferences: _preferences.load(),
    );
  }

  Future<void> dismiss(String notificationId) {
    return _state.dismiss(notificationId);
  }

  Future<void> resetState() {
    return _state.clearAll();
  }
}

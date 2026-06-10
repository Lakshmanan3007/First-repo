import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../domain/notification_preferences.dart';
import '../domain/trace_notification.dart';
import '../data/notification_state_store.dart';

class NotificationCoordinator {
  NotificationCoordinator(this._state);

  final NotificationStateStore _state;

  Future<List<TraceNotification>> evaluate({
    required List<Task> tasks,
    required NotificationPreferences preferences,
    DateTime? now,
  }) async {
    if (!preferences.pushEnabled) {
      return [];
    }

    final effectiveNow = now ?? DateTime.now();
    final dismissed = _state.dismissedIds();
    final alerts = <TraceNotification>[];

    for (final task in tasks) {
      final previous = _state.lastStatusFor(task.id);
      if (previous != task.status) {
        if (task.status == TaskStatus.current) {
          alerts.add(_activeAlert(task));
        } else if (task.status == TaskStatus.failed) {
          alerts.add(_failedAlert(task));
        }
        await _state.setLastStatus(task.id, task.status);
      } else if (previous == null) {
        await _state.setLastStatus(task.id, task.status);
      }

      if (task.status == TaskStatus.current ||
          task.status == TaskStatus.upcoming) {
        final deadlineAlert = _deadlineAlert(
          task,
          preferences: preferences,
          now: effectiveNow,
        );
        if (deadlineAlert != null) {
          alerts.add(deadlineAlert);
        }
      }
    }

    return alerts
        .where((alert) => !dismissed.contains(alert.id))
        .toList();
  }

  TraceNotification _activeAlert(Task task) {
    return TraceNotification(
      id: 'active_${task.id}',
      type: TraceNotificationType.taskActive,
      categoryLabel: 'SYSTEM ALERT',
      message: 'Task is now active.',
      detail: task.name,
      style: TraceNotificationStyle.normal,
      taskId: task.id,
      icon: TraceNotificationIcon.assignment,
    );
  }

  TraceNotification _failedAlert(Task task) {
    return TraceNotification(
      id: 'failed_${task.id}',
      type: TraceNotificationType.taskFailed,
      categoryLabel: 'TERMINATION',
      message: 'Task moved to Failed.',
      detail: task.name,
      style: TraceNotificationStyle.critical,
      taskId: task.id,
      icon: TraceNotificationIcon.error,
    );
  }

  TraceNotification? _deadlineAlert(
    Task task, {
    required NotificationPreferences preferences,
    required DateTime now,
  }) {
    final remaining = task.deadline.difference(now);
    if (remaining.isNegative) return null;

    final minutes = remaining.inMinutes;

    if (minutes <= preferences.tenMinutesRemainingMinutes) {
      return TraceNotification(
        id: 'deadline_${task.id}_critical',
        type: TraceNotificationType.deadlineApproaching,
        categoryLabel: 'CRITICAL',
        message: 'Task deadline',
        detail: '$minutes minutes remaining.',
        style: TraceNotificationStyle.warning,
        taskId: task.id,
        icon: TraceNotificationIcon.calendar,
      );
    }

    if (minutes <= preferences.oneHourRemainingMinutes) {
      return TraceNotification(
        id: 'deadline_${task.id}_warning',
        type: TraceNotificationType.deadlineApproaching,
        categoryLabel: 'TEMPORAL UPDATE',
        message: 'Deadline approaching',
        detail: '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m remaining.',
        style: TraceNotificationStyle.normal,
        taskId: task.id,
        icon: TraceNotificationIcon.calendar,
      );
    }

    return null;
  }
}

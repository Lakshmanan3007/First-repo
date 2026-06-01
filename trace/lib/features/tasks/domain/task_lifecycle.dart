import 'task.dart';
import 'task_status.dart';

/// Time-based status transitions for active tasks (not completed).
abstract final class TaskLifecycle {
  static TaskStatus resolveForNow({
    required TaskStatus currentStatus,
    required DateTime? startTime,
    required DateTime deadline,
    required DateTime now,
  }) {
    if (currentStatus == TaskStatus.completed) {
      return TaskStatus.completed;
    }

    if (deadline.isBefore(now)) {
      return TaskStatus.failed;
    }

    if (currentStatus == TaskStatus.failed) {
      return TaskStatus.failed;
    }

    if (startTime != null && !startTime.isAfter(now)) {
      return TaskStatus.current;
    }

    return TaskStatus.upcoming;
  }

  static Task applyTransition(Task task, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final nextStatus = resolveForNow(
      currentStatus: task.status,
      startTime: task.startTime,
      deadline: task.deadline,
      now: effectiveNow,
    );

    if (nextStatus == task.status) return task;

    return task.copyWith(
      status: nextStatus,
      failedAt: nextStatus == TaskStatus.failed && task.failedAt == null
          ? effectiveNow
          : task.failedAt,
    );
  }
}

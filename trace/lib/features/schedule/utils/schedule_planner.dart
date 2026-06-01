import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../domain/schedule_day_plan.dart';

/// Groups tasks into schedule timeline sections for a selected day.
abstract final class SchedulePlanner {
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) {
    final da = dateOnly(a);
    final db = dateOnly(b);
    return da == db;
  }

  static DateTime effectiveStart(Task task) => task.startTime ?? task.createdAt;

  static bool overlapsDay(Task task, DateTime day) {
    final dayStart = dateOnly(day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final taskStart = effectiveStart(task);
    final taskEnd = task.deadline;
    return taskStart.isBefore(dayEnd) && !taskEnd.isBefore(dayStart);
  }

  static DateTime? archiveTimestamp(Task task) {
    return switch (task.status) {
      TaskStatus.completed => task.completedAt,
      TaskStatus.failed => task.failedAt,
      _ => null,
    };
  }

  static ScheduleDayPlan build({
    required List<Task> tasks,
    required DateTime selectedDay,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final today = dateOnly(effectiveNow);
    final selected = dateOnly(selectedDay);
    final isToday = selected == today;

    final archived = tasks.where((task) {
      final stamp = archiveTimestamp(task);
      return stamp != null && isSameDay(stamp, selected);
    }).toList()
      ..sort((a, b) {
        final aStamp = archiveTimestamp(a)!;
        final bStamp = archiveTimestamp(b)!;
        return aStamp.compareTo(bStamp);
      });

    final inFocus = isToday
        ? (tasks
              .where(
                (task) =>
                    task.status == TaskStatus.current && overlapsDay(task, selected),
              )
              .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline)))
        : <Task>[];

    final queue = tasks.where((task) {
      if (task.status != TaskStatus.upcoming) return false;
      return overlapsDay(task, selected);
    }).toList()
      ..sort((a, b) {
        final aStart = effectiveStart(a);
        final bStart = effectiveStart(b);
        return aStart.compareTo(bStart);
      });

    final tomorrow = selected.add(const Duration(days: 1));
    final tomorrowPreview = isToday
        ? (tasks
              .where(
                (task) =>
                    task.status == TaskStatus.upcoming && overlapsDay(task, tomorrow),
              )
              .toList()
          ..sort((a, b) => effectiveStart(a).compareTo(effectiveStart(b))))
        : <Task>[];

    if (tomorrowPreview.length > 3) {
      tomorrowPreview.removeRange(3, tomorrowPreview.length);
    }

    return ScheduleDayPlan(
      archived: archived,
      inFocus: inFocus,
      queue: queue,
      tomorrowPreview: tomorrowPreview,
    );
  }

  static List<DateTime> weekStripAround(DateTime center) {
    final anchor = dateOnly(center);
    return List.generate(
      7,
      (index) => anchor.subtract(const Duration(days: 3)).add(Duration(days: index)),
    );
  }
}

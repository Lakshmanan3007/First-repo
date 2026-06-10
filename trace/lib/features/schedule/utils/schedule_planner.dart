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

  /// Get time-of-day bucket for a task based on its deadline.
  static String _getTimeBucket(Task task) {
    final hour = task.deadline.hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 21) return 'Evening';
    return 'Night';
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

    // Separate completed and failed tasks for archived section
    final completed = tasks.where((task) {
      final stamp = task.completedAt;
      return stamp != null && isSameDay(stamp, selected);
    }).toList()
      ..sort((a, b) => (a.completedAt ?? DateTime.now()).compareTo(b.completedAt ?? DateTime.now()));

    final failed = tasks.where((task) {
      final stamp = task.failedAt;
      return stamp != null && isSameDay(stamp, selected);
    }).toList()
      ..sort((a, b) => (a.failedAt ?? DateTime.now()).compareTo(b.failedAt ?? DateTime.now()));

    // Get active and upcoming tasks for time-of-day grouping
    final activeTasks = tasks.where((task) {
      return (task.status == TaskStatus.current || task.status == TaskStatus.upcoming) &&
          overlapsDay(task, selected);
    }).toList();

    // Group into time buckets
    final timeBuckets = <String, List<Task>>{
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
      'Night': [],
    };

    for (final task in activeTasks) {
      final bucket = _getTimeBucket(task);
      timeBuckets[bucket]?.add(task);
    }

    // Sort each bucket by deadline
    for (final list in timeBuckets.values) {
      list.sort((a, b) => a.deadline.compareTo(b.deadline));
    }

    // Create time sections
    final timeSections = [
      TimeSection(
        label: 'Morning',
        tasks: timeBuckets['Morning'] ?? [],
        hoursStart: 0,
        hoursEnd: 12,
      ),
      TimeSection(
        label: 'Afternoon',
        tasks: timeBuckets['Afternoon'] ?? [],
        hoursStart: 12,
        hoursEnd: 17,
      ),
      TimeSection(
        label: 'Evening',
        tasks: timeBuckets['Evening'] ?? [],
        hoursStart: 17,
        hoursEnd: 21,
      ),
      TimeSection(
        label: 'Night',
        tasks: timeBuckets['Night'] ?? [],
        hoursStart: 21,
        hoursEnd: 24,
      ),
    ];

    // Tomorrow preview
    final tomorrow = selected.add(const Duration(days: 1));
    final tomorrowPreview = isToday
        ? (tasks
              .where(
                (task) =>
                    task.status == TaskStatus.upcoming && overlapsDay(task, tomorrow),
              )
              .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline)))
        : <Task>[];

    if (tomorrowPreview.length > 3) {
      tomorrowPreview.removeRange(3, tomorrowPreview.length);
    }

    return ScheduleDayPlan(
      timeSections: timeSections,
      completed: completed,
      failed: failed,
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

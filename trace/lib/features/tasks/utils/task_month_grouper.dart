import 'package:intl/intl.dart';

import '../domain/task.dart';
import '../domain/task_status.dart';

class TaskMonthGroup {
  const TaskMonthGroup({
    required this.label,
    required this.monthStart,
    required this.tasks,
  });

  final String label;
  final DateTime monthStart;
  final List<Task> tasks;
}

abstract final class TaskMonthGrouper {
  static final _monthFormat = DateFormat('MMMM yyyy');

  static DateTime? archiveDate(Task task) {
    return switch (task.status) {
      TaskStatus.completed => task.completedAt,
      TaskStatus.failed => task.failedAt,
      _ => null,
    };
  }

  static List<TaskMonthGroup> group(List<Task> tasks, TaskStatus status) {
    if (!status.isArchived || tasks.isEmpty) return [];

    final sorted = List<Task>.from(tasks)
      ..sort((a, b) {
        final aDate = archiveDate(a) ?? a.createdAt;
        final bDate = archiveDate(b) ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

    final groups = <TaskMonthGroup>[];
    DateTime? currentMonth;
    List<Task>? bucket;

    for (final task in sorted) {
      final stamp = archiveDate(task) ?? task.createdAt;
      final monthStart = DateTime(stamp.year, stamp.month);

      if (currentMonth == null ||
          monthStart.year != currentMonth.year ||
          monthStart.month != currentMonth.month) {
        if (bucket != null && bucket.isNotEmpty) {
          groups.add(
            TaskMonthGroup(
              label: _monthFormat.format(currentMonth!),
              monthStart: currentMonth,
              tasks: bucket,
            ),
          );
        }
        currentMonth = monthStart;
        bucket = [task];
      } else {
        bucket!.add(task);
      }
    }

    if (bucket != null && bucket.isNotEmpty && currentMonth != null) {
      groups.add(
        TaskMonthGroup(
          label: _monthFormat.format(currentMonth),
          monthStart: currentMonth,
          tasks: bucket,
        ),
      );
    }

    return groups;
  }
}

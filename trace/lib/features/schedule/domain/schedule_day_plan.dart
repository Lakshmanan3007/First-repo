import '../../tasks/domain/task.dart';

/// Represents a time-of-day section with tasks.
class TimeSection {
  const TimeSection({
    required this.label,
    required this.tasks,
    required this.hoursStart,
    required this.hoursEnd,
  });

  final String label;
  final List<Task> tasks;
  final int hoursStart;
  final int hoursEnd;
}

/// Timeline sections for a single calendar day on the Schedule screen.
class ScheduleDayPlan {
  const ScheduleDayPlan({
    required this.timeSections,
    required this.completed,
    required this.failed,
    required this.tomorrowPreview,
  });

  final List<TimeSection> timeSections;
  final List<Task> completed;
  final List<Task> failed;
  final List<Task> tomorrowPreview;

  bool get isEmpty =>
      timeSections.every((s) => s.tasks.isEmpty) &&
      completed.isEmpty &&
      failed.isEmpty &&
      tomorrowPreview.isEmpty;
}

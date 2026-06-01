import '../../tasks/domain/task.dart';

/// Timeline sections for a single calendar day on the Schedule screen.
class ScheduleDayPlan {
  const ScheduleDayPlan({
    required this.archived,
    required this.inFocus,
    required this.queue,
    required this.tomorrowPreview,
  });

  final List<Task> archived;
  final List<Task> inFocus;
  final List<Task> queue;
  final List<Task> tomorrowPreview;

  bool get isEmpty =>
      archived.isEmpty &&
      inFocus.isEmpty &&
      queue.isEmpty &&
      tomorrowPreview.isEmpty;
}

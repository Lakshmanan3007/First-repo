import '../../schedule/utils/schedule_planner.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../domain/activity_event.dart';

abstract final class ActivityJournalBuilder {
  static ActivityJournal build({
    required List<Task> tasks,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final today = SchedulePlanner.dateOnly(effectiveNow);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(const Duration(days: 7));
    final monthStart = today.subtract(const Duration(days: 30));

    final events = _collectEvents(tasks, monthStart, effectiveNow);
    final summary = _buildSummary(tasks, today, effectiveNow);
    final timeline = [
      ActivityTimelinePeriod(
        label: 'Today',
        events: _eventsInRange(events, today, today.add(const Duration(days: 1))),
      ),
      ActivityTimelinePeriod(
        label: 'Yesterday',
        events: _eventsInRange(
          events,
          yesterday,
          today,
        ),
      ),
      ActivityTimelinePeriod(
        label: 'Past Week',
        events: _eventsInRange(events, weekStart, yesterday),
      ),
      ActivityTimelinePeriod(
        label: 'Past Month',
        events: _eventsInRange(events, monthStart, weekStart),
      ),
    ];
    final upcoming = _upcomingTransitions(tasks, effectiveNow);

    return ActivityJournal(
      summary: summary,
      timeline: timeline,
      upcomingTransitions: upcoming,
    );
  }

  static ActivityTodaySummary _buildSummary(
    List<Task> tasks,
    DateTime today,
    DateTime now,
  ) {
    var completedToday = 0;
    var failedToday = 0;
    var currentCount = 0;
    var upcomingToday = 0;

    for (final task in tasks) {
      if (task.status == TaskStatus.current) currentCount++;
      if (task.status == TaskStatus.upcoming) upcomingToday++;

      final completedAt = task.completedAt;
      if (completedAt != null && SchedulePlanner.isSameDay(completedAt, today)) {
        completedToday++;
      }

      final failedAt = task.failedAt;
      if (failedAt != null && SchedulePlanner.isSameDay(failedAt, today)) {
        failedToday++;
      }
    }

    return ActivityTodaySummary(
      currentCount: currentCount,
      completedToday: completedToday,
      failedToday: failedToday,
      upcomingToday: upcomingToday,
    );
  }

  static List<ActivityEvent> _collectEvents(
    List<Task> tasks,
    DateTime windowStart,
    DateTime now,
  ) {
    final events = <ActivityEvent>[];

    for (final task in tasks) {
      final startTime = task.startTime;
      if (startTime != null &&
          !startTime.isBefore(windowStart) &&
          !startTime.isAfter(now) &&
          startTime.isAfter(task.createdAt.subtract(const Duration(seconds: 1)))) {
        events.add(
          ActivityEvent(
            id: '${task.id}_active',
            at: startTime,
            kind: ActivityEventKind.becameActive,
            title: task.name,
            body: 'Task entered the current queue.',
            taskId: task.id,
          ),
        );
      }

      final completedAt = task.completedAt;
      if (completedAt != null && !completedAt.isBefore(windowStart)) {
        events.add(
          ActivityEvent(
            id: '${task.id}_completed',
            at: completedAt,
            kind: ActivityEventKind.taskCompleted,
            title: task.name,
            body: task.completionNote ?? task.description,
            taskId: task.id,
          ),
        );
      }

      final failedAt = task.failedAt;
      if (failedAt != null && !failedAt.isBefore(windowStart)) {
        events.add(
          ActivityEvent(
            id: '${task.id}_failed',
            at: failedAt,
            kind: ActivityEventKind.taskFailed,
            title: task.name,
            body: task.failureNote ?? task.description,
            taskId: task.id,
          ),
        );
      }
    }

    events.sort((a, b) => b.at.compareTo(a.at));
    return events;
  }

  static List<ActivityEvent> _eventsInRange(
    List<ActivityEvent> events,
    DateTime start,
    DateTime end,
  ) {
    return events
        .where((event) => !event.at.isBefore(start) && event.at.isBefore(end))
        .toList();
  }

  static List<ActivityTransition> _upcomingTransitions(
    List<Task> tasks,
    DateTime now,
  ) {
    final transitions = <ActivityTransition>[];

    for (final task in tasks) {
      if (task.status == TaskStatus.upcoming) {
        final start = task.startTime;
        if (start != null && start.isAfter(now)) {
          transitions.add(
            ActivityTransition(
              taskId: task.id,
              taskName: task.name,
              at: start,
              label: 'Becomes active',
            ),
          );
        }
      }

      if (task.status == TaskStatus.current || task.status == TaskStatus.upcoming) {
        if (task.deadline.isAfter(now)) {
          transitions.add(
            ActivityTransition(
              taskId: task.id,
              taskName: task.name,
              at: task.deadline,
              label: 'Deadline',
            ),
          );
        }
      }
    }

    transitions.sort((a, b) => a.at.compareTo(b.at));
    return transitions.take(8).toList();
  }
}

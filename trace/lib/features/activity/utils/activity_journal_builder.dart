import '../../schedule/utils/schedule_planner.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../domain/activity_event.dart';

abstract final class ActivityJournalBuilder {
  static const _windowDays = 7;
  static const _appVersionLabel = 'v1.0.0_STABLE';

  static ActivityJournal build({
    required List<Task> tasks,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final today = SchedulePlanner.dateOnly(effectiveNow);
    final windowStart = today.subtract(const Duration(days: _windowDays - 1));

    final metrics = _computeMetrics(tasks, windowStart, effectiveNow);
    final events = _collectEvents(tasks, windowStart, effectiveNow);
    final dayGroups = _groupByDay(events, tasks, today);

    return ActivityJournal(
      sessionId: _sessionId(tasks),
      versionLabel: _appVersionLabel,
      metrics: metrics,
      dayGroups: dayGroups,
    );
  }

  static String _sessionId(List<Task> tasks) {
    if (tasks.isEmpty) return '0x0000';
    final seed = tasks.map((t) => t.id.hashCode).reduce((a, b) => a ^ b);
    final hex = (seed & 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
    return '0x$hex';
  }

  static ActivityMetrics7d _computeMetrics(
    List<Task> tasks,
    DateTime windowStart,
    DateTime now,
  ) {
    final windowEnd = now.add(const Duration(days: 1));
    var load = 0;
    var completed = 0;
    var failed = 0;
    var uptimeMinutes = 0;

    for (final task in tasks) {
      final touched = _touchedInWindow(task, windowStart, windowEnd);
      if (touched) load++;

      if (task.completedAt != null &&
          !task.completedAt!.isBefore(windowStart) &&
          task.completedAt!.isBefore(windowEnd)) {
        completed++;
        final start = SchedulePlanner.effectiveStart(task);
        final duration = task.completedAt!.difference(start);
        if (duration.inMinutes > 0) {
          uptimeMinutes += duration.inMinutes;
        }
      }

      if (task.failedAt != null &&
          !task.failedAt!.isBefore(windowStart) &&
          task.failedAt!.isBefore(windowEnd)) {
        failed++;
      }
    }

    final outcomes = completed + failed;
    final health = outcomes == 0 ? 100 : ((completed / outcomes) * 100).round();

    return ActivityMetrics7d(
      loadJobs: load,
      healthPercent: health.clamp(0, 100),
      uptimeHours: (uptimeMinutes / 60).round(),
      syncOk: true,
    );
  }

  static bool _touchedInWindow(Task task, DateTime start, DateTime end) {
    final stamps = [
      task.createdAt,
      task.completedAt,
      task.failedAt,
    ].whereType<DateTime>();

    return stamps.any((stamp) => !stamp.isBefore(start) && stamp.isBefore(end));
  }

  static List<ActivityEvent> _collectEvents(
    List<Task> tasks,
    DateTime windowStart,
    DateTime now,
  ) {
    final events = <ActivityEvent>[];
    final creationsByHour = <String, List<Task>>{};

    for (final task in tasks) {
      if (!task.createdAt.isBefore(windowStart)) {
        final hourKey = _hourBucket(task.createdAt);
        creationsByHour.putIfAbsent(hourKey, () => []).add(task);
      }

      if (task.completedAt != null && !task.completedAt!.isBefore(windowStart)) {
        events.add(
          ActivityEvent(
            id: '${task.id}_completed',
            at: task.completedAt!,
            kind: ActivityEventKind.taskCompleted,
            title: _operationalTitle(task.name),
            body: task.description ??
                'Task closed in operational archive. Validation recorded.',
            tags: task.tags,
            taskId: task.id,
            isPrimary: SchedulePlanner.isSameDay(task.completedAt!, now),
          ),
        );
      }

      if (task.failedAt != null && !task.failedAt!.isBefore(windowStart)) {
        events.add(
          ActivityEvent(
            id: '${task.id}_failed',
            at: task.failedAt!,
            kind: ActivityEventKind.taskFailed,
            title: '${_operationalTitle(task.name)}_FAILED',
            body: 'Lifecycle transition to failed state at deadline.',
            tags: task.tags,
            taskId: task.id,
          ),
        );
      }
    }

    for (final entry in creationsByHour.entries) {
      final batch = entry.value;
      if (batch.length >= 2) {
        events.add(
          ActivityEvent(
            id: 'batch_${entry.key}',
            at: batch.first.createdAt,
            kind: ActivityEventKind.batchCreated,
            title:
                'BATCH_PROC // ${batch.length.toString().padLeft(2, '0')}_JOBS',
            batchTaskNames: batch.map((t) => t.name).toList(),
          ),
        );
      } else {
        final task = batch.single;
        events.add(
          ActivityEvent(
            id: '${task.id}_created',
            at: task.createdAt,
            kind: ActivityEventKind.taskCreated,
            title: 'TASK_INIT // ${_operationalTitle(task.name)}',
            body: 'Registered in operational queue (${task.project}).',
            tags: task.tags,
            taskId: task.id,
          ),
        );
      }
    }

    final currentToday = tasks
        .where(
          (task) =>
              task.status == TaskStatus.current &&
              SchedulePlanner.isSameDay(
                SchedulePlanner.effectiveStart(task),
                now,
              ),
        )
        .toList();
    if (currentToday.isNotEmpty) {
      currentToday.sort(
        (a, b) => SchedulePlanner.effectiveStart(a)
            .compareTo(SchedulePlanner.effectiveStart(b)),
      );
      final first = currentToday.first;
      events.add(
        ActivityEvent(
          id: 'deep_work_${SchedulePlanner.dateOnly(now)}',
          at: SchedulePlanner.effectiveStart(first),
          kind: ActivityEventKind.deepWorkActive,
          title: 'DEEP_WORK_ACTIVE',
          body: 'Focus mode enabled. Active: ${first.name}.',
        ),
      );
    }

    events.sort((a, b) => b.at.compareTo(a.at));
    return events;
  }

  static List<ActivityDayGroup> _groupByDay(
    List<ActivityEvent> events,
    List<Task> tasks,
    DateTime today,
  ) {
    final byDay = <DateTime, List<ActivityEvent>>{};
    for (final event in events) {
      final day = SchedulePlanner.dateOnly(event.at);
      byDay.putIfAbsent(day, () => []).add(event);
    }

    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final groups = <ActivityDayGroup>[];

    for (final day in days) {
      final dayEvents = byDay[day]!..sort((a, b) => b.at.compareTo(a.at));
      final isToday = day == today;
      final isYesterday = day == today.subtract(const Duration(days: 1));

      if (isYesterday && dayEvents.isNotEmpty) {
        final totalMinutes = _completedMinutesOnDay(tasks, day);
        groups.add(
          ActivityDayGroup(
            day: day,
            isToday: false,
            events: [
              ActivityEvent(
                id: 'summary_$day',
                at: DateTime(day.year, day.month, day.day, 23, 59),
                kind: ActivityEventKind.daySummary,
                title: 'LOG_SUMMARY_EOD',
                summarySegments: dayEvents.length,
                summaryDuration: Duration(minutes: totalMinutes),
              ),
              ...dayEvents,
            ],
          ),
        );
      } else {
        groups.add(
          ActivityDayGroup(
            day: day,
            isToday: isToday,
            events: dayEvents,
          ),
        );
      }
    }

    if (!groups.any((g) => g.isToday)) {
      groups.insert(
        0,
        ActivityDayGroup(day: today, isToday: true, events: const []),
      );
    }

    return groups;
  }

  static String _hourBucket(DateTime time) =>
      '${time.year}${time.month}${time.day}${time.hour}';

  static String _operationalTitle(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), '_').toUpperCase();

  static int _completedMinutesOnDay(List<Task> tasks, DateTime day) {
    var minutes = 0;
    for (final task in tasks) {
      final completedAt = task.completedAt;
      if (completedAt == null || !SchedulePlanner.isSameDay(completedAt, day)) {
        continue;
      }
      final span = completedAt.difference(SchedulePlanner.effectiveStart(task));
      if (span.inMinutes > 0) minutes += span.inMinutes;
    }
    return minutes;
  }

  static String formatDurationLabel(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}H ${minutes}M';
    if (hours > 0) return '${hours}H';
    return '${minutes}M';
  }
}

enum ActivityEventKind {
  taskCompleted,
  taskFailed,
  taskCreated,
  batchCreated,
  deepWorkActive,
  daySummary,
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.at,
    required this.kind,
    required this.title,
    this.body,
    this.tags = const [],
    this.batchTaskNames = const [],
    this.taskId,
    this.summarySegments,
    this.summaryDuration,
    this.isPrimary = false,
  });

  final String id;
  final DateTime at;
  final ActivityEventKind kind;
  final String title;
  final String? body;
  final List<String> tags;
  final List<String> batchTaskNames;
  final String? taskId;
  final int? summarySegments;
  final Duration? summaryDuration;
  final bool isPrimary;
}

class ActivityDayGroup {
  const ActivityDayGroup({
    required this.day,
    required this.isToday,
    required this.events,
  });

  final DateTime day;
  final bool isToday;
  final List<ActivityEvent> events;
}

class ActivityMetrics7d {
  const ActivityMetrics7d({
    required this.loadJobs,
    required this.healthPercent,
    required this.uptimeHours,
    required this.syncOk,
  });

  final int loadJobs;
  final int healthPercent;
  final int uptimeHours;
  final bool syncOk;
}

class ActivityJournal {
  const ActivityJournal({
    required this.sessionId,
    required this.versionLabel,
    required this.metrics,
    required this.dayGroups,
  });

  final String sessionId;
  final String versionLabel;
  final ActivityMetrics7d metrics;
  final List<ActivityDayGroup> dayGroups;

  bool get isEmpty => dayGroups.every((group) => group.events.isEmpty);
}

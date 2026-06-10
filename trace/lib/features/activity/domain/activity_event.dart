enum ActivityEventKind {
  taskCompleted,
  taskFailed,
  becameActive,
  reattempted,
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.at,
    required this.kind,
    required this.title,
    this.body,
    this.taskId,
  });

  final String id;
  final DateTime at;
  final ActivityEventKind kind;
  final String title;
  final String? body;
  final String? taskId;

  String get label => switch (kind) {
        ActivityEventKind.taskCompleted => 'Completed',
        ActivityEventKind.taskFailed => 'Failed',
        ActivityEventKind.becameActive => 'Became Active',
        ActivityEventKind.reattempted => 'Reattempted',
      };

  String get iconGlyph => switch (kind) {
        ActivityEventKind.taskCompleted => '✓',
        ActivityEventKind.taskFailed => '✕',
        ActivityEventKind.becameActive => '→',
        ActivityEventKind.reattempted => '⟳',
      };
}

class ActivityTimelinePeriod {
  const ActivityTimelinePeriod({
    required this.label,
    required this.events,
  });

  final String label;
  final List<ActivityEvent> events;

  bool get isEmpty => events.isEmpty;
}

class ActivityTodaySummary {
  const ActivityTodaySummary({
    required this.currentCount,
    required this.completedToday,
    required this.failedToday,
    required this.upcomingToday,
  });

  final int currentCount;
  final int completedToday;
  final int failedToday;
  final int upcomingToday;

  bool get isEmpty =>
      currentCount == 0 &&
      completedToday == 0 &&
      failedToday == 0 &&
      upcomingToday == 0;
}

class ActivityTransition {
  const ActivityTransition({
    required this.taskId,
    required this.taskName,
    required this.at,
    required this.label,
  });

  final String taskId;
  final String taskName;
  final DateTime at;
  final String label;
}

class ActivityJournal {
  const ActivityJournal({
    required this.summary,
    required this.timeline,
    required this.upcomingTransitions,
  });

  final ActivityTodaySummary summary;
  final List<ActivityTimelinePeriod> timeline;
  final List<ActivityTransition> upcomingTransitions;

  bool get isEmpty =>
      summary.isEmpty &&
      timeline.every((period) => period.isEmpty) &&
      upcomingTransitions.isEmpty;
}

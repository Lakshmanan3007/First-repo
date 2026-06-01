enum TaskStatus {
  upcoming,
  current,
  completed,
  failed;

  String get label => switch (this) {
        TaskStatus.upcoming => 'UPCOMING',
        TaskStatus.current => 'CURRENT',
        TaskStatus.completed => 'COMPLETED',
        TaskStatus.failed => 'FAILED',
      };
}

enum TaskStatus {
  upcoming,
  current,
  completed,
  failed;

  static const tabOrder = [
    TaskStatus.current,
    TaskStatus.upcoming,
    TaskStatus.completed,
    TaskStatus.failed,
  ];

  String get label => switch (this) {
        TaskStatus.upcoming => 'UPCOMING',
        TaskStatus.current => 'CURRENT',
        TaskStatus.completed => 'COMPLETED',
        TaskStatus.failed => 'FAILED',
      };

  String get summaryLabel => switch (this) {
        TaskStatus.upcoming => 'Upcoming',
        TaskStatus.current => 'Current',
        TaskStatus.completed => 'Completed',
        TaskStatus.failed => 'Failed',
      };

  int get tabIndex => tabOrder.indexOf(this);

  static TaskStatus fromTabIndex(int index) => tabOrder[index];

  bool get isArchived =>
      this == TaskStatus.completed || this == TaskStatus.failed;
}

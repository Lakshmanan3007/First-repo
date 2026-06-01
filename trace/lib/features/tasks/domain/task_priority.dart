enum TaskPriority {
  low,
  medium,
  high;

  String get label => switch (this) {
        TaskPriority.low => 'LOW',
        TaskPriority.medium => 'MED',
        TaskPriority.high => 'HIGH',
      };

  String get dashboardLabel => switch (this) {
        TaskPriority.low => 'PRIORITY_LOW',
        TaskPriority.medium => 'PRIORITY_STANDARD',
        TaskPriority.high => 'PRIORITY_HIGH',
      };
}

enum TraceNotificationType {
  taskActive,
  deadlineApproaching,
  taskFailed,
}

enum TraceNotificationStyle {
  normal,
  warning,
  critical,
}

class TraceNotification {
  const TraceNotification({
    required this.id,
    required this.type,
    required this.categoryLabel,
    required this.message,
    required this.style,
    this.detail,
    this.taskId,
    this.icon = TraceNotificationIcon.assignment,
  });

  final String id;
  final TraceNotificationType type;
  final String categoryLabel;
  final String message;
  final String? detail;
  final TraceNotificationStyle style;
  final String? taskId;
  final TraceNotificationIcon icon;
}

enum TraceNotificationIcon {
  assignment,
  calendar,
  error,
}

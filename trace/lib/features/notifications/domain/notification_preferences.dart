class NotificationPreferences {
  const NotificationPreferences({
    required this.pushEnabled,
    this.taskActivatedSilent = true,
    this.oneHourRemainingMinutes = 60,
    this.tenMinutesRemainingMinutes = 10,
  });

  final bool pushEnabled;
  final bool taskActivatedSilent;
  final int oneHourRemainingMinutes;
  final int tenMinutesRemainingMinutes;

  static const defaults = NotificationPreferences(
    pushEnabled: true,
    taskActivatedSilent: true,
    oneHourRemainingMinutes: 60,
    tenMinutesRemainingMinutes: 10,
  );

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? taskActivatedSilent,
    int? oneHourRemainingMinutes,
    int? tenMinutesRemainingMinutes,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      taskActivatedSilent: taskActivatedSilent ?? this.taskActivatedSilent,
      oneHourRemainingMinutes:
          oneHourRemainingMinutes ?? this.oneHourRemainingMinutes,
      tenMinutesRemainingMinutes:
          tenMinutesRemainingMinutes ?? this.tenMinutesRemainingMinutes,
    );
  }
}

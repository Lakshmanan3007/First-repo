class NotificationPreferences {
  const NotificationPreferences({
    required this.pushEnabled,
    required this.emailDigests,
    required this.deadlineWarningMinutes,
    required this.deadlineCriticalMinutes,
  });

  final bool pushEnabled;
  final bool emailDigests;
  final int deadlineWarningMinutes;
  final int deadlineCriticalMinutes;

  static const defaults = NotificationPreferences(
    pushEnabled: true,
    emailDigests: false,
    deadlineWarningMinutes: 60,
    deadlineCriticalMinutes: 10,
  );

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailDigests,
    int? deadlineWarningMinutes,
    int? deadlineCriticalMinutes,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailDigests: emailDigests ?? this.emailDigests,
      deadlineWarningMinutes:
          deadlineWarningMinutes ?? this.deadlineWarningMinutes,
      deadlineCriticalMinutes:
          deadlineCriticalMinutes ?? this.deadlineCriticalMinutes,
    );
  }
}
